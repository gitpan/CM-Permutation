package CM::Permutation::Cycle;
use Moose;
use List::AllUtils qw/min max/;
use Data::Dumper;
use Carp;

#note: if you overload in base class you don't need to overload again in derived class
use overload    "==" => 'equal'; # it's better to use sub names instead of coderefs


extends 'CM::Permutation';

has cycle_elements => (
    isa  => 'ArrayRef[Int]',
    is  => 'rw',
    default => sub {[]},
);


sub BUILDARGS {
    my ($self,@args) = @_;

    my @a = 0..max(@args);


    map {
        my $i = $args[ $_   ];
        my $j = $args[ $_+1 ];
        #       say "$i $j";
        $a[$i] = $j;
    } 0..-2+@args;
    #say "$args[-1] $args[0]";
    $a[ $args[-1] ] = $args[0];


    {
        perm            => \@a,
        cycle_elements  => \@args
    };
}

sub BUILD {
    my($self,@args) = @_;
    # check @args has enough arguments
}


# cycles are equal up to a circular permutation
around equal => sub {
    my ($orig,$self,$other) = @_;


    # if the thing we're comparing with is not a cycle then just fall back to normal compare
    return $self->$orig($other) if !$other->isa('CM::Permutation::Cycle'); 

    if($self->$orig($other)){ # first check if they are equal one-by-one
        return 1;
    }

    my @v1 = @{$self->perm};
    my @v2 = @{$other->perm};

    my $i = @v1;
    while($i--) {
        unshift @v1,pop(@v1);
        return 1 if @v1 ~~ @v2;
    };
    return 0;
};

1;
