#
# This file is part of CM-Permutation
#
# This software is copyright (c) 2011 by Stefan Petrea.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use strict;
use warnings;
package CM::Morphism;
{
  $CM::Morphism::VERSION = '0.94';
}
use strict;
use warnings;
use Moose;
use Moose::Util::TypeConstraints;
use List::AllUtils qw/all uniq/;

=pod

=head1 NAME

CM::Morphism - This module describes a group homomorphism


=head1 VERSION

version 0.94

=head1 SEE ALSO

L<http://en.wikipedia.org/wiki/Group_homomorphism>


=cut



use overload '*' => 'composition';

type 'Group'
	=> where {
		$_->does('CM::Group'); # $_ does the role CM::Group
	};



# this will be a group homomorphism which we'll prove 
# step by step to be an epimorphism or a monomorphism
has f => (
	isa      => 'CodeRef',
	is       => 'rw',
	required => 1,
);


# can I write regexes instead of isas ? 

has domain => (
	isa      => 'Group',
	is       => 'rw',
	required => 1,
);



has codomain => (
	isa      => 'Group',
	is       => 'rw',
	required => 1,
);


# prove that this is indeed a morphism
sub prove {
	my ($self) = @_;
	my $f = $self->f;

	confess "undefined" if @{$self->domain->elements}==0;

	all {
		my $x = $_;
		all {
			my $y = $_;

			# * means the group operations here not multiplication..
			$f->( $x   *       $y ) ==
			$f->( $x ) * $f->( $y );

		} @{$self->codomain->elements}
	} @{$self->domain->elements};
}


# the kernel and the image are groups themselves so we should create a subgroup of domain and codomain
sub kernel {
	my ($self) = @_;
	
	my $group = $self->domain->meta->name->new({n=>1});
	$group->compute_elements(sub{});

	my @elements = 
	uniq
	grep {
		$self->f->($_) == 
		$self->codomain->identity;
	} @{$self->domain->elements};

	$group->elements(\@elements);


	return $group;
}

sub image {
	my ($self) = @_;

	my $group = $self->codomain->meta->name->new({n=>1});
	$group->compute_elements(sub{});

	my @elements = 
	uniq
	map {
		$self->f->($_);
	} @{$self->domain->elements};


	$group->elements(\@elements);

	return $group;
}


# compose f o g = h <=> f(g(x)) = h(x)
#
#           f
#      G  -----   H
#        \        |
#         \       |  
#          \      |
#           \     |
#      f o g \    |  g
#             \   |
#              \  |
#               \ |
#                 N

sub composition {
	my ($f,$g) = @_;

	return CM::Morphism->new({
			f        =>
			sub { 
				my ($x) = @_;
				return $f->f->( 
					$g->f->( 
						$x
					)
				);
			},
			domain   => $g->domain,
			codomain => $f->codomain,
	});
}

1;
