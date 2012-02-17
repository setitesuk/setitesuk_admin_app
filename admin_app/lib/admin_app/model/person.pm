
package admin_app::model::person;
use strict;
use warnings;
use base qw(admin_app::model);
use admin_app::model::team_company;
use admin_app::model::person_allowance;
use Carp;
use DateTime;

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_many( [ qw( person_allowance person_team person_admingroup responsibility_for holiday expense_claim ) ] );
__PACKAGE__->has_many_through( [ qw{ team|person_team admingroup|person_admingroup } ] );
__PACKAGE__->has_all();

sub fields {
  return qw( id_person forename initials surname username );
}

sub full_name {
  my ( $self ) = @_;
  my $forename = $self->forename;
  if ( $self->initials ) {
    $forename .= q{ } . $self->initials;
  }
  return $forename . q{ } . $self->surname;
}

sub team {
  my ( $self ) = @_;
  if ( ! $self->{team} ) {
    $self->{team} = @{ $self->teams }[0];
  }
  return $self->{team};
}

sub company {
  my ( $self ) = @_;
  if ( ! $self->{company} ) {
    $self->{company} = $self->team->company;
  }
  return $self->{company};
}

sub team_companies {
  my ( $self ) = @_;
  return admin_app::model::team_company->new->team_companies;
}

sub create {
  my ( $self ) = @_;

  my $util = $self->util;

  my $tx_state = $util->transactions();
  $util->transactions(0);

  $self->SUPER::create();

  $self->_person_team_save();

  admin_app::model::person_allowance->new( { id_person => $self->id_person, person => $self } );

  $util->transactions( $tx_state ) and $util->dbh->commit;

  return 1;
}

sub update {
  my ( $self ) = @_;

  my $util = $self->util;

  my $tx_state = $util->transactions();
  $util->transactions(0);

  $self->SUPER::update();

  $self->_person_team_save();

  $util->transactions( $tx_state ) and $util->dbh->commit;

  return 1;
}

sub _person_team_save {
  my ( $self ) = @_;
  my $cgi = $self->util->cgi();

  my $tc = admin_app::model::team_company->new( {
    id_team_company => $cgi->param( q{id_team_company} ),
  } );

  admin_app::model::person_team->new( {
    id_person => $self->id_person,
    id_team => $tc->id_team,
  } )->save();

  return 1;  
}

sub manager {
  my ( $self ) = @_;
  my $manager;
  eval {
    $manager = @{ $self->responsibility_fors }[0]->manager();
  } or do {
    $manager = $self;
  };
  return $manager;
}

sub manager_to_approve {
  my ( $self ) = @_;
  my $manager = $self;
  my $responsibility_for;
  while ( ! $responsibility_for || $responsibility_for->push_to_further_manager ) {
    $responsibility_for = @{ $manager->responsibility_fors }[0];
    if ( ! $responsibility_for ) {
      return $manager;
    }
    $manager = $responsibility_for->manager;
  }
  return $manager;
}

sub has_subordinates {
  my ( $self ) = @_;
  $self->{has_subordinates} ||= scalar @{ $self->subordinates };
  return $self->{has_subordinates};
}

sub subordinates {
  my ( $self ) = @_;
  $self->{subordinates} ||= admin_app::model::responsibility_for->new( {
    id_manager => $self->id_person()
  } )->subordinates() || [];
  return $self->{subordinates};
}

sub has_admingroups {
  my ( $self ) = @_;
  $self->{has_admingroups} ||= scalar @{ $self->admingroups };
  return $self->{has_admingroups};
}

sub has_expense_claims {
  my ( $self ) = @_;
  $self->{has_expense_claims} ||= scalar @{ $self->expense_claims };
  return $self->{has_expense_claims};
}

sub ordered_expense_claims {
  my ( $self ) = @_;
  my @ecs = @{ $self->expense_claims };

  return [sort { $b->date cmp $a->date } @ecs];
}

sub person_allowance_for_year {
  my ( $self, $year ) = @_;

  $year ||= DateTime->now->year;

  my $allowance;
  foreach my $pa ( @{ $self->person_allowances } ) {
    if ( $pa->year == $year ) {
      $allowance = $pa;
      last;
    }
  }

  if ( $allowance ) {
    return $allowance;
  }

  return admin_app::model::person_allowance->new( {
    id_person => $self->id_person,
    person    => $self,
    year      => $year,
  } );
}

sub holidays_for_year {
  my ( $self, $year ) = @_;

  my @wanted_holidays;

  foreach my $holiday ( @{ $self->holidays } ) {
    if ( $holiday->dt_end->year == $year ) {
      push @wanted_holidays, $holiday;
    }
  }

  return @wanted_holidays;
}

sub is_currently_push_management_responsibilities {
  my ( $self ) = @_;
  return 0 if ! $self->has_subordinates;
  $self->{is_currently_push_management_responsibilities} ||= $self->_set_all_push_management_responsibilities;
  return $self->{is_currently_push_management_responsibilities};
}

# ensure that all management_responsibilities are the same
sub _set_all_push_management_responsibilities {
  my ( $self, $invert ) = @_;

  my $util = $self->util;

  my $tx_state = $util->transactions();
  $util->transactions(0);

  my $new_management_responsibilities;
  foreach my $so ( @{ $self->subordinates } ) {
    my $responsibility_for = @{ $so->responsibility_fors }[0];
    if ( ! defined $new_management_responsibilities ) {
      if ( $invert ) {
        $new_management_responsibilities = ! $responsibility_for->push_to_further_manager;
      } else {
        $new_management_responsibilities = $responsibility_for->push_to_further_manager;
      }
    }
    $responsibility_for->push_to_further_manager( $new_management_responsibilities );
    $responsibility_for->update;
  }

  $util->transactions( $tx_state ) and $util->dbh->commit;
  return $new_management_responsibilities;
  
}

sub invert_push_management_responsibilities {
  my ( $self ) = @_;
  $self->_set_all_push_management_responsibilities( q{invert} );
  $self->{is_currently_push_management_responsibilities} = undef;
  return 1;
}

sub has_holidays_to_approve {
  my ( $self ) = @_;
  return scalar @{ $self->holidays_to_approve };
}

sub holidays_to_approve {
  my ( $self ) = @_;

  if ( $self->{holidays_to_approve} ) {
    return $self->{holidays_to_approve};
  }

  my @wanted_to_approve;
  foreach my $so ( @{ $self->subordinates } ) {
    foreach my $holiday ( @{ $so->holidays } ) {
      if ( ! $holiday->approved || ( $holiday->request_deletion && ! $holiday->deletion_approved ) ) {
        push @wanted_to_approve, $holiday;
      }
    }
    if ( $so->is_currently_push_management_responsibilities ) {
      push @wanted_to_approve, @{ $so->holidays_to_approve };
    }
  }

  foreach my $holiday ( @wanted_to_approve ) {
    $holiday->{manager_approve}++;
  }

  $self->{holidays_to_approve} = \@wanted_to_approve;

  return $self->{holidays_to_approve};
}

1;
 
