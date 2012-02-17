
package admin_app::model::holiday;
use strict;
use warnings;
use base qw(admin_app::model);
use DateTime;
use Carp;
use Readonly;
use POSIX qw{floor};
use List::MoreUtils qw{any};

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a( [ qw( person ) ] );
__PACKAGE__->has_all();

Readonly::Array   our @WEEKEND_DAY_NUMS => ( 6,7 );
Readonly::Scalar  our $SATURDAY         => 6;
Readonly::Scalar  our $SUNDAY           => 7;
Readonly::Scalar  our $WEEK_LENGTH      => 7;

sub fields {
  return qw( id_holiday id_person am approved date_end date_start deletion_approved pm request_deletion );
}

sub create {
  my ( $self ) = @_;

  my $util = $self->util;
  my $dbh = $util->dbh;
  my $class = ref $self;

  my $tx_state = $util->transactions;
  $util->transactions(0);

  my $start_year = $self->dt_start->year;
  my $end_year   = $self->dt_end->year;

  # if a holiday is booked over a year end, then allow this, but create two entries
  if ( $start_year != $end_year ) {
    if ( $start_year + 1 != $end_year ) {
      croak q{Cannot request holiday period } . $self->date_start . q{ -> } . $self->date_end;
    }
    my $first_part = $class->new({
      id_person => $self->id_person,
      date_start => $self->date_start,
      date_end   => $start_year . q{-12-31},
    })->create;
    $self->date_start( $end_year . q{-01-01} );
    $self->{dt_start} = undef;
  }

  # if the person has no manager, then they should approve themselves
  if ( $self->person->manager->id_person == $self->id_person ) {
    $self->{approved} = 1;
  }

  $self->SUPER::create;

  # ensure that there is a person_allowance set up for year
  $self->person->person_allowance_for_year( $end_year );


  $self->_calculate_remaining( $end_year );

  $util->transactions($tx_state) and $dbh->commit;

  return 1;
}

sub update {
  my ( $self ) = @_;

  my $util = $self->util;
  my $dbh = $util->dbh;
  my $id_manager = $util->cgi->param( q{id_manager} );

  if ( $id_manager ) {
    my $person = $self->person;
    my $manager = $self->person->manager_to_approve;
    if ( $id_manager != $manager->id_person ) {
      croak q{this manager is unable to approve};
    }
  }

  # if the person has no manager, then they should approve themselves
  if ( $self->person->manager->id_person == $self->id_person ) {
    if ( $self->{request_deletion} ) {
      $self->{deletion_approved} = 1;
    }
    $self->{approved} = 1;
  }

  my $tx_state = $util->transactions;
  $util->transactions(0);

  $self->SUPER::update;

  $self->_calculate_remaining;

  $util->transactions($tx_state) and $dbh->commit;

  return 1;
}

sub dt_start {
  my ( $self ) = @_;

  if ( ! $self->{dt_start} ) {
    $self->{dt_start} = $self->_dt_date( $self->{date_start} );
  }

  return $self->{dt_start};
}

sub dt_end {
  my ( $self ) = @_;

  if ( ! $self->{dt_end} ) {
    $self->{dt_end} = $self->_dt_date( $self->{date_end} );
  }

  return $self->{dt_end};
}

sub _dt_date {
  my ( $self, $date ) = @_;
  my ( $year, $month, $day ) = $date =~ m/(\d{4})-(\d{2})-(\d{2})/xms;
  return DateTime->new( {
    year => $year, month => $month, day => $day,
  } );
}

sub _calculate_remaining {
  my ( $self ) = @_;
  
  my $person = $self->person();

  my $person_allowance = $person->person_allowance_for_year( $self->dt_end->year );
  my $total_allowance = $person_allowance->total_allowance;

# does not yet account for bank holidays!!!

  foreach my $holiday ( $person->holidays_for_year( $self->dt_end->year ) ) {

    my $dt_start  = $holiday->dt_start;
    my $dt_end    = $holiday->dt_end;

    my $number_of_days = $dt_start->delta_days( $dt_end )->days;
    $number_of_days++; # holidays should be inclusive
    if ( $holiday->am || $holiday->pm ) {
      $number_of_days = 0.5;
    }

    my $start_day_week_num  = $dt_start->day_of_week;
    my $end_day_week_num    = $dt_end->day_of_week;
    my $num_of_week_boundaries = floor ( $number_of_days / $WEEK_LENGTH );

    if ( $num_of_week_boundaries ) {
       my $weekend_days = scalar @WEEKEND_DAY_NUMS * $num_of_week_boundaries;
       $num_of_week_boundaries -= $weekend_days;
    } else {
      if ( any { $start_day_week_num  == $_ } @WEEKEND_DAY_NUMS ) {
        $number_of_days--;
        if ( $start_day_week_num == $SATURDAY ) {
          $number_of_days--;
        }
      }
      if ( any { $end_day_week_num    == $_ } @WEEKEND_DAY_NUMS ) {
        $number_of_days--;
        if ( $end_day_week_num == $SUNDAY ) {
          $number_of_days--;
        }
      }
    }

    if ( $number_of_days < 0 ) {
      $number_of_days = 0;
    }

    if ( $holiday->approved ) {
      $total_allowance -= $number_of_days;
    }

    if ( $holiday->deletion_approved ) {
      $total_allowance += $number_of_days;
    }
  }

  $total_allowance = $total_allowance > $person_allowance->total_allowance ? $person_allowance->total_allowance : $total_allowance;

  $person_allowance->remaining( $total_allowance );
  return $person_allowance->save;
}


1;
 
