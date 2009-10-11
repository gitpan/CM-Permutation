use strict;
use warnings;
use lib './lib/';
use CM::Group::Sym;
use Data::Dumper;
use feature 'say';
use Test::More 'no_plan';
use List::AllUtils qw/uniq/;


my $g = CM::Group::Sym->new({n=>3});

my @all = map { @{$_} } 
            @{$g->operation_table};


# we know |S_3| = 3! = 6   so we're going to use that as a test
ok(scalar(uniq(@all))==6,'S_3 has 6 elements');



#if labelling is changed this test has to be changed as well
my $table = "$g";
ok($table eq
qq{6 5 4 3 2 1
5 6 3 4 1 2
4 1 2 5 6 3
3 2 1 6 5 4
2 3 6 1 4 5
1 4 5 2 3 6
},'operation table for S_3 calculated correctly');
ok($g->str_perm eq
qq{1 -> 3 2 1
2 -> 2 3 1
3 -> 2 1 3
4 -> 3 1 2
5 -> 1 3 2
6 -> 1 2 3
},'permutation labels are ok');



#print $table;
#print $g->str_perm;
#$g->draw_cayley_digraph;



