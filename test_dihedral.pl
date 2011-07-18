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
use CM::Group::Dihedral;
my $g = CM::Group::Dihedral->new({n=>10});
$g->compute;
$g->rearrange;
print "$g";
