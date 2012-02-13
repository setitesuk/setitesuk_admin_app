
package admin_app::model;
use strict;
use warnings;
use base qw(ClearPress::model);
use DateTime;
use admin_app::model::person;

sub date_today {
  my ( $self ) = @_;
  my $dt = DateTime->now();
  return $dt->ymd . q{ } . $dt->hms;
}

sub all_people {
  my ( $self ) = @_;
  return admin_app::model::person->new->people;
}

sub id_manager {
  my ( $self, $id_manager ) = @_;
  if ( $id_manager ) {
    $self->{id_manager} = $id_manager;
  }
  return $self->{id_manager};
}

1;
 
