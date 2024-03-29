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
use strict;
use warnings;
use Rubik::Model;
use Rubik::View;
use Test::More;


my $view = Rubik::View->new();
my $model= Rubik::Model->new({view=>$view});

my $array_not_cross =
[
[21 , 24 , 27] ,
[23 , 5  , 26] ,
[20 , 2  , 3]  ,
];


my $array_cross =
[
[21 , 8 , 27] ,
[4  , 5 , 6]  ,
[20 , 2 , 3]  ,
];

sub at_least_cross {
	# checks to see if there is at least a cross on that face
	my ($arr2D) = @_;
	my $str = join(',',map { @$_ }(@$arr2D));
	my $num = '\d+'; # number
	my $cnum= '(\d+)';# number captured
	my @captures = $str =~ /
	$num  , $cnum , $num  ,
	$cnum , $cnum , $cnum ,
	$num  , $cnum , $num
	/xs;
	return $model->same_face(@captures);
};

ok(!at_least_cross($array_not_cross),"arrary is not cross");
ok(at_least_cross($array_cross),"arrary is cross");





