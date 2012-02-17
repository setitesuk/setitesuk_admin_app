
package admin_app::view::person;
use strict;
use warnings;
use base qw(ClearPress::view);

sub edit_management_responsibility {
  my ( $self ) = @_;
  $self->template_name('person/read');
  return $self->model->invert_push_management_responsibilities;
}

1;
 
