
package admin_app::model::email_rule;
use strict;
use warnings;
use base qw(admin_app::model);

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_many([qw( company )]);
__PACKAGE__->has_all();

sub fields {
  return qw( id_email_rule rule );
}

1;
 
