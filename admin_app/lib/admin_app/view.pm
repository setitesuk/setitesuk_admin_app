
package admin_app::view;
use strict;
use warnings;
use base qw(ClearPress::view);

sub authorised {
  my $self      = shift;
  my $util      = $self->util;
  my $requestor = $util->requestor;

  if ( $requestor && $requestor->is_member_of_admingroup( q{application_administration} ) ) {
    return 1;
  }

  return $self->SUPER::authorised;
}


sub add {
  my ( $self ) = @_;
  my $cgi = $self->util->cgi;
  my $id_person = $cgi->param( q{id_person} );
  if ( $id_person && ! $self->model->id_person) {
    $self->model->{id_person} = $id_person;
  }
  return $self->SUPER::add;
}

1;
 
