
package admin_app::model::team;
use strict;
use warnings;
use base qw(admin_app::model);
use Carp;
use admin_app::model::company;
use admin_app::model::team_company;

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_many( [ qw( team_company person_team ) ] );
__PACKAGE__->has_many_through( [ qw( company|team_company person|person_team ) ] );
__PACKAGE__->has_all();

sub fields {
  return qw( id_team teamname );
}

sub company {
  my ( $self ) = @_;
  if ( ! $self->{company} ) {
    $self->{company} = @{ $self->companies() }[0];
  }
  return $self->{company};
}

sub all_companies {
  my ( $self ) = @_;
  return admin_app::model::company->new->companies;
}

sub create {
  my ( $self ) = @_;
  my $util = $self->util();
  my $cgi = $util->cgi();

  my $tx_state = $util->transactions();
  $util->transactions(0);

  $self->SUPER::create();
  
  my $tc = admin_app::model::team_company->new( {
    id_team => $self->id_team(),
    id_company => $cgi->param( q{id_company} ),
  } )->save();

  $util->transactions($tx_state) and $util->dbh->commit;

  return 1;
}

sub update {
  my ( $self ) = @_;

  my $cgi = $self->util->cgi();
  my $id_company_param = $cgi->param( q{id_company} );
  if ( $id_company_param and $id_company_param ne $self->company->id_company() ) {
    croak q{You may not change the company this team belongs to.<br />Are you sure you didn't mean just to change the name of the company?};
  }
  return $self->SUPER::update();
}

1;
 
