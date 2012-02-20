
package admin_app::view::holiday;
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
         ( $model->person->manager_to_approve->id_person && $model->person->manager_to_approve->id_person == $id_req ) ) {
           return 1;
         }
  }

  return $self->SUPER::authorised;
}

sub edit {
  my ( $self ) = @_;

  my $cgi = $self->util->cgi;

  my $model = $self->model;
  $model->id_manager( $cgi->param( q{id_manager} ) );
  return $self->SUPER::edit;
}

1;
 
