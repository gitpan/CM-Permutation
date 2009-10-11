package CM::Permutation;
use strict;
use warnings;
use Moose;
use List::AllUtils qw/reduce all any first uniq/;
use Carp;
use Data::Dumper;
use feature 'say';
use overload    "*" => \&multiply,
                "**" => \&power,
                "==" => \&equal,
                '""' => 'stringify'; # "" and == are used by uniq from List::AllUtils in the tests
use Storable qw/dclone/;
use List::AllUtils qw/min max/;

use 5.010000;


require Exporter;
our @ISA;
push @ISA,qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';



has label => (
    isa => 'Str',
    is  => 'rw',
);

has perm => (
    isa => 'ArrayRef[Int]',
    is  => 'rw',
    default => sub {[]},
);

sub BUILDARGS {
    my ($self,@perm) = @_;

    confess "too many arguments to constructor, ambigous permutation"
        if scalar(@perm) > max(@perm);

    confess "not enough arguments to constructor, ambigous permutation"
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
    
    confess "duplicates are not allowed"
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
    my @tuples = map { [$_,$self->perm->[$_]] } 0..-1+@{$self->perm};
    @tuples = sort { $a->[1] <=> $b->[1] } @tuples;

    shift @tuples;# get rid of first 0 , so that we can do the constructor below
    my $inverse = CM::Permutation->new( map{ $_->[0] } @tuples );
    return $inverse;
}

sub equal {
    my ($self,$other) = @_;
    return 0 if scalar(@{$self->perm}) != scalar(@{$other->perm});
    return all { ; $self->perm->[$_] == $other->perm->[$_] } 0..-1+@{$other->perm};
}


sub multiply {
    # the naming $right , $left is weird but it corresponds to order of elements in multiplication

    my ($right,$left) = map{dclone $_}@_[0..1];

    #left needs to be as big as right in terms of elements of ->perm so that it does not have any undefs in unwanted places
    my $maxright = max(@{$right->perm});
    my $maxleft  = max( @{$left->perm});
    sub stretch {
        my ($me,$mleft,$mright) = @_;
        if($me->isa('CM::Permutation::Cycle')) {
            $me->perm->[$_] = $_
            for min($mleft,$mright)+1..max($mleft,$mright);
        }
    };

    if( $maxleft<$maxright ) {
        stretch($left ,$maxleft,$maxright)
    }elsif ( $maxleft>$maxright ) {
        stretch($right,$maxleft,$maxright);
    };

    my $new_perm = dclone($left);
    #print Dumper $right;exit;

    my $tube = sub {
        my ($x) = @_;
        return $right->perm->[
            $left->perm->[$x]
        ];
    };



    $new_perm->perm->[$_] = $tube->($_)
        for 1..max($maxright,$maxleft);


    return $new_perm;
}

sub order {
    my ($self) = @_;
}

=pod

=head1 NAME

CM::Permutation - Module for manipulating permutations 

=head1 DESCRIPTION

The module was written for carrying out permutation operations.
The module is not written for generating permutations or counting them(to that end you can use L<Algorithm::Permute> or L<Math::Counting>)

At the moment the following are implemented(any feature that is currently listed as implemented has tests proving it):

=over

=item * inverse of a permutation

=item * cycle decomposition

=item * power of a permutation

=item * '==' operator implemented

=back


=head1 TODO

=over

=item * breaking cycles into transpositions( maybe making a transposition class)

=item * writing as much tests as possible

=item * rewrite tests using the equal operator

=item * writing routine is_cycle() to check if a permutation is a cycle

=item * get Cycle_Algorithm to use ArrayRef[CM::Permutation::Cycle] instead of what it's using now for storing the cycles and re-write tests

=item * add order() method for ::Permutation (will be different for ::Permutation::Cycle , where just the length is the order) and will be computed as gcd of lenghts of cycles.::Permutation (will be different for ::Permutation::Cycle , where just the length is the order) and will be computed as gcd of lenghts of cycles.

=item * constructing a separate module or in this module to make the table of operations for a particular S_n

=item * making a routine that will check if a subgroup's operation table is equal to some particular subgroup of some S_n(since order of S_n is n! above n>5 there isn't much hope for this) and if so identify them as being isomorphic.

=item * writing code for calculating the subgroup lattice of a group S_n and representing it in a nice way 

=item * hardcoding well-known groups , their isomorphic subgroup of S_n and using that before an exhaustive check in the previous point

=back


=head1 AUTHOR

Stefan Petrea, C<< <stefan.petrea at gmail.com> >>

=head1 SEE ALSO

L<Algorithm::Permute> or L<Math::Counting> 

L<http://en.wikipedia.org/wiki/Cycle_(mathematics)>

=cut

1;



