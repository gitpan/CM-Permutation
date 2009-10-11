use strict;
use warnings;
use lib './lib/';
use CM::Permutation;
use Data::Dumper;
use Test::More 'no_plan';
use List::AllUtils qw/all/;

sub eq_perm {
    my $expect = $_[1]; # deeply doesn't work because for some reason some numbers have been stringfied(will check this later)

        (
            all{
                $_[0]->perm->[$_] == $expect->[$_];
            }
            (1..-1+@$expect)
        ),
}


ok(!eval{ my $n = CM::Permutation->new(4,8,2,3);    } ,'not enough arguments to constructor');
eval "my \$n = CM::Permutation->new(4,1,2,3);";
ok( !$@ ,'enough arguments to constructor');

my $w = CM::Permutation->new(4,1,2,3);
ok(eq_perm($w**2 ,[0,3,4,1,2]),'squared permutation all in place');
ok(eq_perm($w**-1,[0,2,3,4,1]),'inverse works right');
ok(eq_perm($w*($w**-1),[0,1,2,3,4]),'inverse identitiy is pretty much ok');
ok(eq_perm(($w**-1)*$w,[0,1,2,3,4]),'again the inverse identitiy is fine');
ok($w==$w,'permutation equals itself');
ok($w*($w**-1)==CM::Permutation->new(1,2,3,4),'w*w^-1 equals the identical permutation');


sub p{
    CM::Permutation->new(@_);
}


ok(p(1,3,2)*p(1,2,3)==p(1,3,2),'multiplied with identity stays the same');
ok(p(2,1,3)*p(1,2,3)==p(2,1,3),'again multiplied with identity stays the same');

ok(p(1,3,2)*p(3,1,2)==p(2,1,3),"supposed to be 2,1,3");




