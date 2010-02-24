#!/usr/local/bin/perl
# 
# This file is part of CM-Permutation
# 
# This software is copyright (c) 2010 by Stefan Petrea.
# 
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
# 
use strict;
use warnings;
#!/usr/bin/perl

#switch between the first two lines depending on what system I am
use strict;
use Pod::Simple::HTML;

my $parser = Pod::Simple::HTML->new();

if (defined $ARGV[0]) {
    open IN, $ARGV[0]  or die "Couldn't open $ARGV[0]: $!\n";
} else {
    *IN = *STDIN;
}

if (defined $ARGV[1]) {
    open OUT, ">$ARGV[1]" or die "Couldn't open $ARGV[1]: $!\n";
} else {
    *OUT = *STDOUT;
}

$parser->index(1);
$parser->html_css('http://search.cpan.org/s/style.css');

$parser->output_fh(*OUT);
$parser->parse_file(*IN);

