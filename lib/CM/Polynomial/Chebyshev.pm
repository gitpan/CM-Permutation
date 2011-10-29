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
package CM::Polynomial::Chebyshev;
{
  $CM::Polynomial::Chebyshev::VERSION = '0.94';
}
use strict;
use warnings;
use Moose;
extends 'Math::Polynomial';
use Data::Dumper;


=head1 DESCRIPTION

Given cos(x) the Chebyshev polynomials offer a way of quickly finding cos(nx)
(check tests for more details on this).

=cut

 
sub new {
	my ($self,$n) = @_;

	$self->SUPER::new(@{ cheb($n)->[0] });

};



sub cheb {
	my ($n) = @_;

	#print "cheb $n\n";
	return Math::Polynomial->new(1)
	if $n == 0;

	return Math::Polynomial->new(0,1)
	if $n == 1;

	return Math::Polynomial->new(0,2) * cheb($n-1) - cheb($n-2);
}

1;
