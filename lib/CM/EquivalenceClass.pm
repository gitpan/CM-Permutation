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
package CM::EquivalenceClass;
{
  $CM::EquivalenceClass::VERSION = '0.94';
}
use Moose;
use Set::Scalar;

use overload '==' => 'equal';

=pod

=head1 NAME

CM::EquivalenceClass - Module for describing equivalence classes

=head1 VERSION

version 0.94

This module is just a stub for the moment.



=cut


# TODO: this is in initial phase of implementation(there's a lot of stuff to fill in here).


# implementation problems
# -----------------------
#
# how do I choose representant for a class ?
#
# how is multiplication of equivalence classes carried out if I don't know what the elements of the
# equivalence class of the results are(at most I'll know the representant)
#
# when I pass representant an element other than a representant then it should identify what the real
# representat should have been ?

has representant => (
	isa      => 'Any',
	is       => 'rw',
	required => 1,
);

has label => (
	isa      => 'Int',
	is       => 'rw',
	required => 1,
);


has elements => (
	isa      => 'ArrayRef',
	is       => 'rw',
	required => 1 ,
);


sub equal {
	my ($x,$y) = @_;
	# two equivalence classes are equal if they have at least one element in common
	# (or .. their representants are equal)
	
	return 1 if $x->representant == $y->representant;
	
        # * means intersection for Set::Scalar
	return (
			Set::Scalar->new(@{$x->elements}) * 
			Set::Scalar->new(@{$y->elements})
			)->size;
}
