package admin_app::controller;

use strict;
use warnings;
use Carp;
use English qw(-no_match_vars);
use base qw{ClearPress::controller};
use Readonly; Readonly::Scalar our $VERSION => 0.1;

use admin_app::decor;
use admin_app::util;
use admin_app::model;
use admin_app::model::admingroup;
use admin_app::model::company;
use admin_app::model::email_rule;
use admin_app::model::expense_claim;
use admin_app::model::holiday;
use admin_app::model::holiday_allowance;
use admin_app::model::person;
use admin_app::model::person_admingroup;
use admin_app::model::person_allowance;
use admin_app::model::person_team;
use admin_app::model::responsibility_for;
use admin_app::model::team;
use admin_app::model::team_company;
use admin_app::view::admingroup;
use admin_app::view::company;
use admin_app::view::email_rule;
use admin_app::view::expense_claim;
use admin_app::view::holiday;
use admin_app::view::holiday_allowance;
use admin_app::view::person;
use admin_app::view::person_admingroup;
use admin_app::view::person_allowance;
use admin_app::view::person_team;
use admin_app::view::responsibility_for;
use admin_app::view::team;
use admin_app::view::team_company;

=head1 NAME

admin_app::controller

=head1 VERSION

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 new

create a new controller object

=head2 decorator

=cut

sub decorator {
  my ( $self, $util ) = @_;

  if ( $self->{decorator} ) {
    return $self->{decorator};
  }

  #########
  # important to pass the cgi object in
  #
  my $version = $VERSION;
  my $decor   = admin_app::decor->new( {
    title      => "Admin App LIMS r$version",
    cgi        => $util->cgi,
    stylesheet => $util->config_stylesheets,
    jsfile     => $util->config_jsfiles,
  } );

  #########
  # as we have our decorator here, let's fetch credentials from website login
  #
  if ( ! $util->requestor() ) {
    my $preferred_unauthenticated = q{public};
    my $hua = $ENV{HTTP_USER_AGENT} || q[];

    my $username = $decor->username() || $preferred_unauthenticated;
    my $user     = admin_app::model::person->new( {
			username => $username,
		} );
		$user->read;
    $util->requestor($user);

  } elsif ( $util->requestor->id_user ) {
    $decor->session( $util->requestor->session );
  }

  $self->{decorator} = $decor;
  return $decor;
}


1;
__END__

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item strict

=item warnings

=item Carp

=item English -no_match_vars

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

$Author: Andrew Brown$

=head1 LICENSE AND COPYRIGHT

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut
