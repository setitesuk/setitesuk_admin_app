
package admin_app::view::holiday;
use strict;
use warnings;
use base qw(ClearPress::view);

sub edit {
  my ( $self ) = @_;

  my $cgi = $self->util->cgi;

  my $model = $self->model;
  $model->id_manager( $cgi->param( q{id_manager} ) );
  return $self->SUPER::edit;
}

1;
 
