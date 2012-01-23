
package admin_app::model::company;
use strict;
use warnings;
use base qw(ClearPress::model);
use admin_app::model::email_rule;

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a( [ qw( email_rule ) ] );
__PACKAGE__->has_many( [ qw( team_company holiday_allowance ) ] );
__PACKAGE__->has_many_through( [ qw( team|team_company ) ] );
__PACKAGE__->has_all();

sub fields {
  return qw( id_company id_email_rule email_domain name );
}

sub email_rules {
  my ( $self ) = @_;
  return admin_app::model::email_rule->new->email_rules();
}

1;
 
