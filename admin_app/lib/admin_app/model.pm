
package admin_app::model;
use strict;
use warnings;
use base qw(ClearPress::model);
use DateTime;

sub date_today {
  my ( $self ) = @_;
  my $dt = DateTime->now();
  return $dt->ymd . q{ } . $dt->hms;
}

1;
 
