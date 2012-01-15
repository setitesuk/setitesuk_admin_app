
package admin_app::model::person;
use strict;
use warnings;
use base qw(ClearPress::model);

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a([qw()]);
__PACKAGE__->has_many([qw(person_allowance person_team person_admingroup responsibility_for holiday expense_claim )]);
__PACKAGE__->has_all();

sub fields {
  return qw(id_person
	    
	    forename initials surname username );
}

1;
 
