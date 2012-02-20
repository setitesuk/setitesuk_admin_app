
package admin_app::view::person;
use strict;
use warnings;
use base qw(admin_app::view);

sub authorised {
  my ( $self ) = @_;

  my $model = $self->model;
  my $util = $self->util;
  my $requestor = $util->requestor;
  my $id_req = $requestor->id_person || 0;
  my $id_person = $model->id_person;
  my $aspect = $self->aspect;

  if ( ! $id_person && $aspect ne q{add} ) {
    return 1;
  }


  if ( $requestor ) {

    if ( $aspect eq q{add} && $requestor->is_member_of_admingroup( q{HR} ) ) {
      return 1;
    }

    if ( $id_req == $id_person
          ||
         $id_req == $model->manager->id_person
          ||
         $id_req == $model->manager_to_approve->id_person ) {
           return 1;
         }
  }

  return $self->SUPER::authorised;
}

sub edit_management_responsibility {
  my ( $self ) = @_;
  $self->template_name('person/read');
  return $self->model->invert_push_management_responsibilities;
}

1;
 
