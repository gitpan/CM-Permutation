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
package CM::Group::ModuloAddition;
use Moose;
extends 'CM::Group::ModuloMultiplication';


=head1 DESCRIPTION

The group (Z_n,+)

=cut

sub operation {
    my ($self,$a,$b) = @_;

    my $result = ($a->object + $b->object) % $self->n;
    my $element = CM::ModuleInt->new( $result );
    $element->label( $a->object * $b->object );

    return $element;
}


1;
