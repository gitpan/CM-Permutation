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
package CM::Permutation;
our $VERSION = '0.4';
use strict;
use warnings;
use Moose;
use List::AllUtils qw/sum reduce all any first uniq min max first_index/;
use Carp;
use Data::Dumper;
use Math::BigInt qw/blcm/;
use Params::Validate;

# require is used here because there is the following dependency chain
#
# Permutation -> Cycle_Algorithm -> Cycle -> Permutation
#
# so it's circular and 'require' solves this

require CM::Permutation::Cycle_Algorithm;
#use feature 'say';
use overload    "*" => \&multiply,
                "*=" => \&mul_as,
                "**" => \&power,
                "^"  => \&conj,
                "%"  => "com",
                "<<" => \&conjugate,
                "==" => \&equal,
                "!=" => sub{ !equal(@_); },
                "cmp"=> \&equal,
                "eq" => \&equal,
                '""' => 'stringify'; # "" and == are used by uniq from List::AllUtils in the tests
use Storable qw/dclone/;
use 5.010000;

has label => (
    isa => 'Str',
    is  => 'rw',
);

has perm => (
    isa => 'ArrayRef[Int]',
    is  => 'rw',
    default => sub {[]},
);


#belonging group(could be S_n or some subgroup of S_n..)
has group => (
    isa => 'Any',
    is  => 'rw',
    default => undef,
    weak_ref=> 1,
);

sub BUILDARGS {
    my ($self,@perm) = @_;


    if(ref($_[1]) eq 'HASH') {
        # this will be a way to write a permutation as
        # CM::Permutation->new({ key => sigma(key) , key2 => sigma(key2) ... })

        my $h = $_[1];
        my $max = max(values(%$h));
        my @p = (0,1..$max);

        for(1..$max){
            $p[$_] = exists($h->{$_})
                     ? $h->{$_}
                     : $_;
        };

        my @m = (0) x (~~@perm);


        #print "HASH";
        #print Dumper \@p;

        return
        {
            perm    => \@p,
            marked  => \@m,
        };
    };

    #print "NOTHASH";
    #print Dumper \@perm;

    confess 'was not expecting any 0s or undefined in permutation'
        if(any{ !defined($_) || $_ == 0 }@perm);

    confess "too many arguments to constructor, ambigous permutation(a number repeats at least twice)"
        if scalar(@perm) > max(@perm);

    confess "not enough arguments to constructor, ambigous permutation(numbers missing)"
        if scalar(@perm) < max(@perm);

    @perm = (0,@perm);
    my @m = map{0} @perm;
    {
        perm    => \@perm,
        marked  => \@m,
    }
}

sub BUILD {
    my ($self) = @_;
    #TODO -> have to make constructor accept other Permutation objects
    
    confess("duplicates are not allowed [".join(',',@{$self->perm}))
        unless scalar(uniq(@{ $self->perm })) == scalar(@{ $self->perm });
}

sub stringify {
    my ($self) = @_;
    my @p = @{$self->perm};
    shift @p;
    join(' ',@p);
}

sub power {
    #for now supports powers -1 and >=1
    my ($self,$power) = @_;
    return $self->inverse if $power == -1;
    

    my $r = $self;
    while(--$power) {
        my $n = $r * $self;
        $r = $n;
    };
    return $r;
}

sub inverse {
    my ($self) = @_;
#        if($self->group && $self->label){
#            #inverse from op table
#            if($inv_cache[$self->label]){
#                return $inv_cache[$self->label];
#            };
#            my $o = $self->group->operation_table; #operation table
#            my $row = $o->[$self->group->order - $self->label];
#            my $e = $self->group->identity;
#            my $index_inverse = first_index {
#                $e->label == $_->label
#            } @$row;
    #
#            $inv_cache[$self->label] = $o->[0]->[$index_inverse];
#            return $o->[0]->[$index_inverse];
#        }


    my @tuples = map { [$_,$self->perm->[$_]] } 0..-1+@{$self->perm};
    @tuples = sort { $a->[1] <=> $b->[1] } @tuples;

    shift @tuples;# get rid of first 0 , so that we can do the constructor below
    my $inverse = CM::Permutation->new( map{ $_->[0] } @tuples );

    return $inverse;
}

# TODO:need check that both @_ are C::P
sub equal {
    return 0 unless $_[0];
    return 0 unless $_[1];
    if($_[0]->label && $_[1]->label) {
#        say "iar!!";
        return $_[0]->label == $_[1]->label;
    };
    my ($self,$other) = @_;
    return 0 if scalar(@{$self->perm}) != scalar(@{$other->perm});
    return all { ; $self->perm->[$_] == $other->perm->[$_] } 0..-1+@{$other->perm};
}



sub multiply {
# the naming $right , $left is weird but it corresponds to order of elements in multiplication
#    if($_[0]->label && $_[1]->label && $_[0]->group) {
#        say "called";
##        say $_[0]->label;
##        say $_[1]->label;
#
#        my $o = $_[0]->group->operation_table;
#        my $u = $_[0]->group->order;
#        return $o->[
#            $u - $_[0]->label
#        ]->[
#            $u - $_[1]->label
#        ];
#    };

    my ($right,$left) = @_;


    # make them each as long as the other


    my $l1 = @{$right->perm};
    my $l2 = @{$left->perm};
    my $max = max($l1,$l2);

    if($l1<$max) {
        $right->perm->[$_] = $_ for $l1..$max-1;
    };

    if($l2<$max) {
        $left->perm->[$_]  = $_ for $l2..$max-1;
    };

    die "NOT EQUAL!!!" if ~~@{$left->perm} != ~~@{$right->perm};

    #print "\n";
    #print "$right\n$left\n";

    my @p = 
    map {
        my $L = $left->perm->[$_];
        my @ret = 
        ($L)
        ? ($right->perm->[$L])
        : ();
        #print "L= ".$left->perm->[$_]."R= ".$right->perm->[$_]."    |  $_ @ret\n";
        @ret;
    } (1..$max);

    return CM::Permutation->new(@p);
}

sub get_cycles {
    my ($self) = @_;
    my @v = @{$self->perm};
    shift @v;
    my $alg = CM::Permutation::Cycle_Algorithm->new(@v);
    return $alg->run;
}

######################################################################
#this is somewhat asymettrical because Cycle derives from Permutation
#but order() in Cycle is used by order() in Permutation
######################################################################

sub order {
    #
    #sidenote: the maximum order of an element in S_n can be determined by taking
    #all partitions of n and computing lcm of each partitions elements and the biggest lcm
    #is the maximum order of an element in S_n
    #(this is because every permutation is the product of disjoint cycles, and order of the cycles is their own
    #length, and the sums of their orders must add up to n)
    #
    #
    my ($self) = @_;
    blcm(map { $_->order;  } $self->get_cycles);
}


# returns 1 -> odd , 0 -> even
sub even_odd {
    my ($self) = @_;
    my @type;#will store type of permutation( position i with value k will mean k cycles of length i in permutation)
    map { $type[$_->order]++; } $self->get_cycles;

    return sum(
        map{
            ($_-1)*($type[$_]//0);
        } 
        (1..-1+@type)
    ) & 1;
}

# for some reason mul_as doesn't work

sub mul_as {
    $_[0] = $_[0] * $_[1];
}



#conjugate
#
sub conj {
    my ($b,$a) = @_;
    ($a**-1)*$b*$a;
}


# commutator
sub com {
    my ($a,$b) = @_;
    ($a**-1)*($b**-1)*$a*$b;
}


# if there is a g \in G so that  g*a*g^-1 = b then a ~ b (a and b are conjugates)

sub conjugate {
    my ($a,$b) = @_;# $a is actually $self
    confess 'a undefined' unless $a;
    confess 'b undefined' unless $b;
    confess 'no group for a' unless $a->group;
    confess 'no group for b' unless $b->group;
    #confess "element doesn't have a group" unless $a->group ;
#    say Dumper $a->group;
#    say Dumper $b->group;
#    exit;
    my $i = 0;
    return first {
#        say $i++;
        $_*$a*($_**-1) == $b
    } @{$a->group->elements};
}


# TODO: to find out if passing reference to the array so it can be modified would be better ?
# or just modify it inplace using the @_ ?
# TODO:add tests for this
sub apply {
    my ($self,@set) = @_;
    my @ret;

    my @p = @{$self->perm};
    shift @p;# the front 0


    @ret = map { $set[$_-1] }  @p; # -1 to be in @set indexes

    @ret = (@ret , @set[max(@p)..-1+@set]);


    # put the non-permuted part back in the result, we don't want to upset noone


    return @ret;
}


# consider the permutation a function on finite sets
# same as apply but with a twist, it will run the sub with each pair of argument/value to the permutation
# so for the permutation  [3,1,2] the following calls will be made
# $sub->(1,3)
# $sub->(2,1)
# $sub->(3,2)

sub apply_sub {
    my ($self,$sub,@set) = @_;
    map { $sub->($_,$self->perm->[$_]); } 
    0..-1+@{$self->perm};
}





=pod

=head1 NAME

CM::Permutation - Module for manipulating permutations 

=head1 VERSION

version 0.4

=head1 DESCRIPTION

The module was written for carrying out permutation operations.
The module is not written for generating permutations or counting them(to that end you can use L<Algorithm::Permute> or L<Math::Counting>)

At the moment the following are implemented(any feature that is currently listed as implemented has tests proving it):

=over

=item * permutation composition and conjugate permutations

=item * inverse of a permutation

=item * "power" of a permutation

=item * '==' operator implemented (eq is the same)

=item * order() method

=item * even_odd(x) to classify even and odd permutations

=item * conjugate(x,y) which test if there is a g so that x = g y g^-1

=item * get_cycles() decomposes permutation into cycles and returns them

=back


=head1 AUTHOR

Stefan Petrea, C<< <stefan.petrea at gmail.com> >>

=head1 SEE ALSO

L<Algorithm::Permute> or L<Math::Counting> 

L<http://en.wikipedia.org/wiki/Cycle_(mathematics)>

L<CM::Group::Sym>

L<CM::Group::Altern>

=cut

1;