
package admin_app::model::admingroup;
use strict;
use warnings;
use base qw(admin_app::model);

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_many( [ qw( person_admingroup ) ] );
__PACKAGE__->has_many_through( [ qw( person|person_admingroup ) ] );
__PACKAGE__->has_all();

sub fields {
  return qw( id_admingroup groupname );
}

1;
 
