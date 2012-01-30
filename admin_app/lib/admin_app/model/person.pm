
package admin_app::model::person;
use strict;
use warnings;
use base qw(admin_app::model);
use admin_app::model::team_company;

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_many( [ qw( person_allowance person_team person_admingroup responsibility_for holiday expense_claim ) ] );
__PACKAGE__->has_many_through( [ qw{ team|person_team admingroup|person_admingroup } ] );
__PACKAGE__->has_all();

sub fields {
  return qw( id_person forename initials surname username );
}

sub full_name {
  my ( $self ) = @_;
  my $forename = $self->forename;
  if ( $self->initials ) {
    $forename .= q{ } . $self->initials;
  }
  return $forename . q{ } . $self->surname;
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

sub manager {
  my ( $self ) = @_;
  my $manager;
  eval {
    $manager = @{ $self->responsibility_fors }[0]->manager();
  } or do {
    $manager = $self;
  };
  return $manager;
}

sub has_subordinates {
  my ( $self ) = @_;
  return scalar @{ $self->subordinates };
}

sub subordinates {
  my ( $self ) = @_;
  my $return = admin_app::model::responsibility_for->new( {
    id_manager => $self->id_person()
  } )->subordinates() || [];
  return $return;
}

sub has_expense_claims {
  my ( $self ) = @_;
  return scalar @{ $self->expense_claims };
}

sub ordered_expense_claims {
  my ( $self ) = @_;
  my @ecs = @{ $self->expense_claims };

  return [sort { $b->date cmp $a->date } @ecs];
}

1;
 
