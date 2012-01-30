
package admin_app::model::team_company;
use strict;
use warnings;
use base qw(admin_app::model);

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a( [ qw( team company ) ] );
__PACKAGE__->has_all();

sub fields {
  return qw( id_team_company id_team id_company );
}

1;
 
