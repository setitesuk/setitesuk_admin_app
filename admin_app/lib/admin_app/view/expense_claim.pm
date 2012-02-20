
package admin_app::view::expense_claim;
use strict;
use warnings;
use base qw(admin_app::view);

sub authorised {
  my $self      = shift;
  my $util      = $self->util;
  my $requestor = $util->requestor;
  my $model     = $self->model;
  my $table     = $model->table;
  my $aspect    = $self->aspect;
  my $action    = $self->action;

  if ( $requestor ) {
    my $id_req    = $requestor->id_person || 0;
    my $id_person = $model->id_person     || 0;
    if ( $aspect eq q{add} || $id_req == $id_person 
          ||
         $requestor->is_member_of_admingroup( q{HR} )
          ||
         ( $model->person->manager_to_approve->id_person && $model->person->manager_to_approve->id_person == $id_req ) ) {
           return 1;
         }
  }

  return;
}


1;
 
