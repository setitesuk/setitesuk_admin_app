
package admin_app::model::person_allowance;
use strict;
use warnings;
use base qw(admin_app::model);

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a( [ qw( person ) ] );
__PACKAGE__->has_all();

sub fields {
  return qw( id_person_allowance id_person carried_forward pro_rata_allowance remaining total_allowance year );
}

1;
 
