use strict;
use warnings;
use lib './lib/';
use CM::Permutation::Cycle;
use CM::Permutation;
use CM::Group::Sym;
use Data::Dumper;
use Test::More 'no_plan';
use List::AllUtils qw/all uniq/;
#use feature 'say';
use Math::BigInt;


sub p{
    CM::Permutation->new(@_);
}


sub eq1 {
    my $p1=shift;
    $p1==p(@_);
}


ok(!eval{ my $n = CM::Permutation->new(4,8,2,3);    } ,'not enough arguments to constructor');
eval "my \$n = CM::Permutation->new(4,1,2,3);";
ok( !$@ ,'enough arguments to constructor');

my $w = CM::Permutation->new(4,1,2,3);

ok($w==$w                       ,'permutation equals itself');

# ~~@array is the same as scalar(@array)
is(2,~~uniq( (p(1,2,3),p(3,1,2))x4 ),'two permutation 5 times');

ok(eq1($w**2        ,3,4,1,2)   ,'squared permutation all in place');
ok(eq1($w**-1       ,2,3,4,1)   ,'inverse works right');
ok(eq1($w*($w**-1)  ,1,2,3,4)   ,'inverse identitiy is pretty much ok');
ok(eq1(($w**-1)*$w  ,1,2,3,4)   ,'again the inverse identitiy is fine');
ok(eq1($w*($w**-1)  ,1,2,3,4)   ,'w*w^-1 equals the identical permutation');




ok(p(1,3,2)*p(1,2,3)==p(1,3,2),'multiplied with identity stays the same');
ok(p(2,1,3)*p(1,2,3)==p(2,1,3),'again multiplied with identity stays the same');
ok(p(1,3,2)*p(3,1,2)==p(2,1,3),"supposed to be 2,1,3");



ok( CM::Group::Sym->new({n=>7})->order() % p(1,5,4,3,6,2,7)->order == 0 , 'applying Lagrange theorem , order of perm (1,5,4,3,6,2,7) divides order of group S_7');
#(1)*(5,2)*(4,3)

# testing Lagrange on a random permutation would be nice also ( but would that still constitute a test?)


# testing inverse done with the use of the computed operation table
my $g = CM::Group::Sym->new({n=>3});
$g->compute;
ok(defined $g->identity,'identity from group defined');
ok($g->identity == p(1,2,3),'identity from group ok');
my $p4 = $g->operation_table->[4]->[0];
#say "$p4 has inverse ".$p4->inverse;
ok($p4*($p4**-1) == $g->identity,"permutation ($p4) with inverse (".$p4->inverse.")");











