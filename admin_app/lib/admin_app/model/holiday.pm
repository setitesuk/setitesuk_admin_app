
package admin_app::model::holiday;
use strict;
use warnings;
use base qw(admin_app::model);

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a( [ qw( person ) ] );
__PACKAGE__->has_all();

sub fields {
  return qw( id_holiday id_person am approved date_end date_start deletion_approved pm request_deletion );
}

1;
 
