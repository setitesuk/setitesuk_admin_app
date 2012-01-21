
package admin_app::model::person;
use strict;
use warnings;
use base qw(ClearPress::model);
use admin_app::model::team_company;

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a([qw()]);
__PACKAGE__->has_many([qw(person_allowance person_team person_admingroup responsibility_for holiday expense_claim )]);
__PACKAGE__->has_many_through( [ qw{team|person_team} ] );
__PACKAGE__->has_all();

sub fields {
  return qw( id_person forename initials surname username );
}

sub team {
  my ( $self ) = @_;
  if ( ! $self->{team} ) {
    $self->{team} = @{ $self->teams }[0];
  }
  return $self->{team};
}

sub company {
  my ( $self ) = @_;
  if ( ! $self->{company} ) {
    $self->{company} = $self->team->company;
  }
  return $self->{company};
}

sub team_companies {
  my ( $self ) = @_;
  return admin_app::model::team_company->new->team_companies;
}

sub create {
  my ( $self ) = @_;

  my $util = $self->util;

  my $tx_state = $util->transactions();
  $util->transactions(0);

  $self->SUPER::create();

  $self->_person_team_save();

  $util->transactions( $tx_state ) and $util->dbh->commit;

  return 1;
}

sub update {
  my ( $self ) = @_;

  my $util = $self->util;

  my $tx_state = $util->transactions();
  $util->transactions(0);

  $self->SUPER::update();

  $self->_person_team_save();

  $util->transactions( $tx_state ) and $util->dbh->commit;

  return 1;
}

sub _person_team_save {
  my ( $self ) = @_;
  my $cgi = $self->util->cgi();

  my $tc = admin_app::model::team_company->new( {
    id_team_company => $cgi->param( q{id_team_company} ),
  } );

  admin_app::model::person_team->new( {
    id_person => $self->id_person,
    id_team => $tc->id_team,
  } )->save();

  return 1;  
}

1;
 
