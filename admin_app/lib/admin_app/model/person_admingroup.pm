
package admin_app::model::person_admingroup;
use strict;
use warnings;
use base qw(admin_app::model);
use admin_app::model::admingroup;

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a( [ qw( person admingroup ) ] );
__PACKAGE__->has_all();

sub fields {
  return qw( id_person_admingroup id_person id_admingroup );
}

sub admingroups {
  my ( $self ) = @_;
  return admin_app::model::admingroup->new->admingroups;
}

1;
 
