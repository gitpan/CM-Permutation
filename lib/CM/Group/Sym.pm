# 
# This file is part of CM-Permutation
# 
# This software is copyright (c) 2009 by Stefan Petrea.
# 
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
# 
use strict;
use warnings;
package CM::Group::Sym;
our $VERSION = '0.065';
use Moose;
use CM::Permutation;
use CM::Permutation::Cycle_Algorithm;
use Algorithm::Permute;
use Text::Table;
#use feature 'say';
use List::AllUtils qw/uniq reduce first first_index/;
use overload '""' => 'stringify';
use Math::BigInt;
use GraphViz;

=pod

=head1 NAME

CM::Group::Sym - An implementation of the finite symmetric group S_n

=head1 VERSION

version 0.065

=head1 DESCRIPTION

CM::Group::Sym is an implementation of the finite Symmetric Group S_n

=head1 SYNOPSIS

    use CM::Group::Sym;
    my $G = CM::Group::Sym->new({$n=>3});
    $G->compute();

This way you will generate S_3 with all it's 6 elements which are permutations.
Say you want to print the operation table(Cayley table).
    
    print $G

    6 5 4 3 2 1
    3 4 5 6 1 2
    2 1 6 5 4 3
    5 6 1 2 3 4
    4 3 2 1 6 5
    1 2 3 4 5 6

Note that those are only labels for the elements as printing the whole permutations
would render the table useless since they wouldn't fit.

So if you want to see the meaning of the numbers(the permutations behind them) you can use str_perm()

    print $G->str_perm;

    1 -> 3 2 1
    2 -> 2 3 1
    3 -> 2 1 3
    4 -> 3 1 2
    5 -> 1 3 2
    6 -> 1 2 3

=cut


has n => (
    isa => 'Int',
    is  => 'rw',
    default => undef,
    required => 1,
);

has order => (
    isa => 'Int',
    is  => 'rw',
    lazy => 1,
    default => sub {
        # n! is the order of this group
        # haven't tried to generate S_n above n=5 , but
        # n = 5 itself would actually generate a 720x720 matrix with 518400 cells,
        # in each cell will lie one permutation , so it will be slow
        my $self = shift;
        reduce { $a * $b  } 1..$self->n;
    }
);


#or Cayley table , however you want to call it
has operation_table => (
    isa => 'ArrayRef[ArrayRef[CM::Permutation]]',
    is  => 'rw',
    default => sub{[]},
);

has elements => (
    isa => 'ArrayRef[CM::Permutation]',
    is  => 'rw',
    default => sub {[]},
);


# todo -> cache permutations by string representations to make * faster
sub stringify {
    my ($self) = @_;
    my $table = Text::Table->new;
    my $order = $self->order; #reduce { $a * $b  } 1..$self->n;
    my @for_table;
    for my $i (0..-1+$order) {
        my @new_line = map{ $_->label  } @{$self->operation_table->[$i]};
        push @for_table,\@new_line;
    }
    $table->load( @for_table );
    return "$table";
}


sub label_to_perm {
    my ($self,$label) = @_;
    my $where = $self->order - $label;
    return $self->operation_table->[0]->[$where];
}

# gets the label of the inverse of some permutation whos label is given as a parameter
sub get_inverse {
    # $self->order - $element becuse the elements are ordered differently because
    # A::Permutation enumrates them differently ...
    my ($self,$element) = @_;
    my $row = $self->order - $element;
    confess 'argument given is not in range of labels(which is 1..n! for S_n)'
        unless( $row>=0 && $row <= -1+$self->order );
    for my $column(0..-1+$self->order) {
        return $self->operation_table->[0]->[$column]->label if 
            $self->operation_table->[$row]->[$column]->label == $self->order;
    }
}


sub idempotent {
    #takes labels not perm at arguments
    my ($self,$element) = @_;
    my $i = $self->order - $element;

    confess 'argument given is not in range of labels(which is 1..n! for S_n)'
        unless( $i>=0 && $i <= $self->order );

    my $result = $self->operation_table->[$i]->[$i]->label;
    return $element == $result;
}


sub str_perm {
    my ($self) = @_;
    join(
        "\n",
        map {
            my $label   = $_->label;
            my $str     = "$_";
            "$label -> $str";
        } @{$self->elements}
    );
}

sub BUILD {
    my ($self) = @_;
};



# generate all permutations of the set {1..n}
sub gen_perms {
    my ($self) = @_;
    my $label = 0;
    my @permutations;
    my $p = new Algorithm::Permute([1..$self->n]);
    while (my @new_perm = $p->next) {
        my $new_one = CM::Permutation->new(@new_perm);
        $new_one->label(++$label);
        unshift @permutations,$new_one;
    };
    return @permutations;
}

sub perm2label {
    my ($self,$perm) = @_;
    return
        ( first { $_ == $perm } @{$self->elements} )->label;
}

sub label2perm { }

# compute all elements of the group
sub compute {
    my ($self) = @_;
    $self->elements([$self->gen_perms]);

    my $order = $self->order;
    # *ij is actually an alias(typeglob) to $self->operation_table->[$i]->[$j]
    for my $i (0..-1+$order) {
        for my $j (0..-1+$order) {
            local *i   = \$self->elements->[$i];
            local *j   = \$self->elements->[$j];
            local *ij   = \$self->operation_table->[$i]->[$j];
            ${*ij} = ${*i} * ${*j};
            ${*ij}->label($self->perm2label(${*ij}));
        }
    }
}



# coset of an element g \in G for the subgroup H<G is   gH = {g*h1,g*h2,...,g*hn} where n=|H|
sub coset {
    my ($self,$g,$H) = @_;
    # g must be in self
    # H must be subgroup of G(no way to check that yet)

    return
    uniq
    map { $self->perm2label($_); }
    map { $g * $_ } 
    @{$H->elements};
}


#after writing this I checked CPAN and it seems that Algorithm::EquivalenceSets does
#something very similar , and then conj_classes is the same as(not as complexity, just functionality)
#
#equivalence_sets(
#   map {
#       my $a = $_;
#       map {
#           $a->conjugate($_)
#           ? [$a,$_]
#           : ()
#       } @{$self->elements}
#   } @{$self->elements}
#)
#
#this is more slow and would have been much smaller but I'm avoiding the overhead

#find conjugate classes (this could be factored out in CM::Algorithm::EquivalenceClasses as a Moose Role)
sub conj_classes {
    #TODO:  find out where memory leak resides in this sub
    #       it gets memory to 85% for 1GB ram, not very good
    my ($self) = @_;

    # if I put this(2lines below)
    # in ->gen_perms instead I get a 20s delay the cause of which I was unable to find ...
    # with either the Perl debugger or Devel::NYTProf 
    $self->elements->[$_]->group($self) 
    for 0..-1+@{$self->elements};



    confess 'no group on element in $self'
    unless $self->elements->[0]->group;

    my @Classes;# equivalence classes

    my @gelems = @{$self->elements};
    for my $to_place (@gelems) {
        my $where = -1;
        my $i_class;#class number
        for my $i_class(0..-1+@Classes) {
            next if @{$Classes[$i_class]} < 1;
            my $first_from_class = $Classes[$i_class]->[0];

            my $g = first {
#                say "another test";
#                say $_->label;
#                say $to_place->label;
#                $_*($to_place*($_**-1)) == $first_from_class
                 $_*($to_place*($_**-1)) == $first_from_class
            } @gelems; # if there is a $g then $to_place and $first_from_class are conjugates
                       # first() will return undef if there is no such $g
            if($g) {# or we could do this as well which is slower -> if( $to_place << $first_from_class ){
                $where = $i_class;
                last;
            };
        };
        if($where < 0) { # haven't found a class for it, make room
            push @Classes,[];
            $where = ~~@Classes - 1 ;
        };
        push @{ $Classes[$where] } , $to_place
    }
    return @Classes;
}


# this will do the same thing(classify elements in conjugation classes) but
# using the fact that the conjugation classes correspond directly to the type of cycle
# decomposition that a permutation has
# for example S_4 has 5 classes
#
# (x)(x)(x)(x)
# (xx)(x)(x)
# (xx)(xx)
# (xxx)(x)
# (xxxxx)
# 
# where xs are elements of a cycle
#
# by comparison with conj_classes this(_fast) works much faster but requires additional knowledge
# about the group in question(symmetric group in this case) whereas conj_classes is generic enough to
# work for any group(which has a conjugation relation on it)

sub conj_classes_fast {
    my ($self) = @_;
    # a href where conjugacy classes will be kept inside arrayrefs in the values
    # and the keys will be labels of the form   "c1,c2,..,cn" where ci will be the lengths
    # of the cycles making up permutations belonging to that conjugacy class, the ci will be
    # sorted
    my $class_href = {};
    for my $p (@{ $self->elements }) {
        # how can I promote a CM::Permutation object to CM::Permutation::Cycle_Algorithm ?
        # (because they are related classes and it should be easy to inject in ISA something and
        # get to ::Cycle_Algorithm)
        
        # the label contains the sorted lengths of the cycles of $p separated by a comma
        my $label = join(",",
            (
                sort 
                map { ~~@{ $_->cycle_elements}; } 
                $p->get_cycles
            )
        );
        $class_href->{$label} = [] 
            unless $class_href->{$label};
        push @{$class_href->{$label}},
            $p;
#        print "($p) $label\n"; 
    };



    map {
        $class_href->{$_}
    }
    sort { $a < $b } keys %$class_href;
}


=pod

=head1 compute()

Computes the operation table.

=head1 draw_cayley_digraph($path)

This method will draw the cayley digraph of the group to png to the given $path.
You can read the graph as follows.
An edge from X to Y with a label Z on it that means X * Z = Y where X,Y,Z are labels of permutations.
Beyond n=3 it's very hard to understand anything in the diagram(because S_n is a big group in general).

=head1 NOTES

Internally the permutations are stored in arrayref of arrayrefs and each cell contains a CM::Permutation object.

The tests are consisted of well-known results such as Lagrange theorem and the Class equation for groups at the moment, but they can/will be extended in the future with other well-known results.

If you take a look in the cde the Class equation for groups is tested like this:

    $g->order == ~~($g->center) + sum(map { ~~@{$_} } @classes)

Lagrange's theorem is tested like this:

    CM::Group::Sym->new({n=>7})->order() % p(1,5,4,3,6,2,7)->order == 0

The ease with which you can express this equation in Perl makes it a very good candidate for implementing
abstract algebra in.

=head1 TODO



=over

=item * cache_perms to store permutations instead of storing them inside operation_table
and 2 methods label2perm and perm2label

=item * writing code for calculating the subgroup lattice of a group S_n and representing it in a nice way 

=item * hardcoding well-known groups , their isomorphic subgroup of S_n and using that before an exhaustive check in the previous point

=item * making a routine that will check if a subgroup's operation table is equal to some particular subgroup of some S_n(since order of S_n is n! above n>5 there isn't much hope for this) and if so identify them as being isomorphic.

=back

=cut

sub draw_cayley_digraph {
    my ($self,$path) = @_;
    my $order = $self->order;
    my $graph = GraphViz->new(
        center => 1 ,
        ratio => 'fill',
        width => 30,
        height => 30,
        layout => 'twopi'
    );
    for my $i (0..-1+$order) {
        for my $j (0..-1+$order) {
            my $from    = $self->operation_table->[0]->[$j]->label;
            my $to      = $self->operation_table->[$i]->[$j]->label;
            my $with    = $self->operation_table->[$i]->[0]->label;
            #say "from=$from to=$to with=$with";
            $graph->add_edge(
                $from => $to,
                label => $with
            );
        }
    };
    $graph->as_png($path // "/var/www/docs/graph.png");
}

sub identity {
    my ($self) = @_;
    my $e = CM::Permutation->new(1..$self->n);
    first {
        $_ == $e;
    } @{ $self->operation_table->[0] };
}


# centralizer of an element in the group
# TODO: replace in all the code $self->order - index with index and fix all tests after that

sub centralizer {
    my ($self,$a) = @_;
    my $i=
    $a->label
    ? $self->order - $a->label
    : $self->order - $self->perm2label($a);

    my @central;
    for my $j (0..-1+$self->order) {
        
        push @central, $self->operation_table->[$j]->[0]
            if( $self->operation_table->[$i]->[$j]->label ==
                $self->operation_table->[$j]->[$i]->label
            );
    };

    return @central;
}


sub center {
    my ($self) = @_;
    my @result;
    for my $g ( @{$self->elements} ) {
        my @centralizer = $self->centralizer($g);
#        say "($g) has ".scalar(@centralizer)." elements in centralizer";
        push @result,$g
            if(scalar(@centralizer)==$self->order)
    };
    return @result;
}



# orbit should also be implemented.
# 
# if f:GxX -> G is a group action of G on X
# f(g,x)
# then f(G,x) is the orbit of x


=pod

=head1 AUTHOR

Stefan Petrea, C<< <stefan.petrea at gmail.com> >>

=cut

1;