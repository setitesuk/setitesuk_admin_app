
package admin_app::model::company;
use strict;
use warnings;
use base qw(ClearPress::model);

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a([qw(email_rule )]);
__PACKAGE__->has_many([qw(team_company )]);
__PACKAGE__->has_all();

sub fields {
  return qw(id_company
	    id_email_rule 
	    email_domain name );
}

1;
 
