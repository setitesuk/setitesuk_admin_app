
package admin_app::model::expense_claim;
use strict;
use warnings;
use base qw(admin_app::model);
use admin_app::model::person;
use DateTime;

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a( [ qw( person ) ] );
__PACKAGE__->has_all();

sub fields {
  return qw(id_expense_claim id_person date hr_approved invoice_submitted long_description manager_approved paid short_description );
}

sub all_people {
  my ( $self ) = @_;
  return admin_app::model::person->new->people;
}

sub create {
  my ( $self ) = @_;
  $self->_check_date_exists();
  return $self->SUPER::create;
}

sub update {
  my ( $self ) = @_;
  $self->_check_date_exists();
  return $self->SUPER::update;
}

sub _check_date_exists {
  my ( $self ) = @_;
  my $cgi = $self->util->cgi();
  if ( ! $self->{date} ) {
    return;
  }
  my $date = $cgi->param( q{date} );
  if ( $date ) {
    return;
  }

  $self->{date} = $self->date_today;
  return;  
}

1;
 
