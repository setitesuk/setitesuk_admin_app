
package admin_app::model::person_allowance;
use strict;
use warnings;
use base qw(admin_app::model);
use DateTime;
use Carp;

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a( [ qw( person ) ] );
__PACKAGE__->has_all();

sub fields {
  return qw( id_person_allowance id_person carried_forward pro_rata_allowance remaining total_allowance year );
}

sub init {
  my ( $self ) = @_;

  my $pk = $self->primary_key;
  my $table = $self->table;

  if ( ! $self->{id_person} ) {
    croak q{No person allocated};
  }

  if ( ! $self->{$pk} && $self->{id_person} ) {

    if ( ! $self->{year} ) {
      my $self->{year} = DateTime->now->year();
    }

    my $query = qq{
      select $pk from $table
      where id_person = ? and year = ?
    };

    my $id = $self->util->dbh->selectall_arrayref($query, {}, $self->{id_person}, $self->{year})->[0]->[0];

    if ( $id ) {
      $self->{$pk} = $id;
    } else {
      my $ha_for_year = $self->{person}->company->holiday_allowance_for_year( $self->{year} );
      $self->{pro_rata_allowance} = $ha_for_year->standard_allowance;
      $self->{remaining} = $self->{total_allowance} = $self->{pro_rata_allowance};
      $self->{carried_forward} = 0;
      $self->{year} = $ha_for_year->year;
      $self->save;
    }
  }

  return 1;
}

1;
 
