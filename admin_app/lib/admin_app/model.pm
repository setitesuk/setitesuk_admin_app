
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

1;
 
