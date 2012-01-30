
package admin_app::model::person_team;
use strict;
use warnings;
use base qw(admin_app::model);

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a( [ qw( person team )]);
__PACKAGE__->has_all();

sub fields {
  return qw( id_person_team id_person id_team );
}

1;
 
