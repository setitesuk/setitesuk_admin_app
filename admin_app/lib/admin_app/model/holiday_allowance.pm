
package admin_app::model::holiday_allowance;
use strict;
use warnings;
use base qw(admin_app::model);
use admin_app::model::company;

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a( [ qw( company ) ] );
__PACKAGE__->has_all();

sub fields {
  return qw( id_holiday_allowance id_company standard_allowance year );
}

sub companies {
  my ( $self ) = @_;
  my @companies = sort { $a->name cmp $b->name } @{ admin_app::model::company->new->companies };
  return @companies;
}

1;
 
