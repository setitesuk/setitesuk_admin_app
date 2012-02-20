
package admin_app::util;
use strict;
use warnings;
use base qw(ClearPress::util);

sub config_jsfiles {
  my ( $self ) = @_;
  my $jsfiles = $self->config->{v}->{application}->{jsfiles};
  return [ ( split m/,/xms, $jsfiles ) ];
}

sub config_stylesheets {
  my ( $self ) = @_;
  my $stylesheets = $self->config->{v}->{application}->{stylesheet};
  return [ ( split m/,/xms, $stylesheets ) ];
}

1;
 
