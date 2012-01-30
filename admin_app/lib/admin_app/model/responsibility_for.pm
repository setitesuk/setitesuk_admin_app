
package admin_app::model::responsibility_for;
use strict;
use warnings;
use base qw(admin_app::model);
use admin_app::model::person;

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a( [ qw( person ) ] );
__PACKAGE__->has_many([qw()]);
__PACKAGE__->has_all();

sub fields {
  return qw( id_responsibility_for id_person id_manager push_to_further_manager );
}

sub manager {
  my ( $self ) = @_;
  if ( ! $self->{manager} ) {
    $self->{manager} = admin_app::model::person->new({
      id_person => $self->id_manager(),
    });
  }
  return $self->{manager};
}

sub subordinates {
  my ( $self ) = @_;

  if ( $self->{subordinates} ) {
    return $self->{subordinates};
  }

  my $table = $self->table;

  my $query = <<"EOT";
select * from $table where id_manager = ?
EOT

  foreach my $so ( @{ $self->gen_getarray( ref $self, $query, $self->id_manager ) } ) {
    push @{ $self->{subordinates} }, $so->person;
  }

  return $self->{subordinates};
}

1;
 
