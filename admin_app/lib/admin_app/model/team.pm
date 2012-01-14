
package admin_app::model::team;
use strict;
use warnings;
use base qw(ClearPress::model);

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a([qw()]);
__PACKAGE__->has_many([qw(person_team )]);
__PACKAGE__->has_all();

sub fields {
  return qw(id_team
	    
	    teamname );
}

1;
 
