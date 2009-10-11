package CM::Group::Sym;
use Moose;
use CM::Permutation;
use Algorithm::Permute;
use Text::Table;
use feature 'say';
use List::AllUtils qw/reduce first/;
use overload '""' => 'stringify';
use GraphViz;

=pod

=head1 NAME

CM::Group::Sym - An implementation of the symmetric group S_n

=head1 DESCRIPTION

CM::Group::Sym is an implementation of the Symmetric Group 

=head1 SYNOPSIS

    use CM::Group::Sym;
    my $G = CM::Group::Sym->new({$n=>3});

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
        # I haven't tried to generate above n=5 , but
        # n = 5 itself would actually generate a 720x720 matrix with 518400 cells,
        # in each cell will lie one permutation , so it will be slow
        my $self = shift;
        reduce { $a * $b  } 1..$self->n
    }
);


#or Cayley table , however you want to call it
has operation_table => (
    isa => 'ArrayRef[ArrayRef[CM::Permutation]]',
    is  => 'rw',
    default => sub{[]},
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

sub str_perm {
    my ($self) = @_;
    my $p = new Algorithm::Permute([1..$self->n]);
    my $label = 0;
    my $res;
    while (my @new_perm = $p->next) {
        ++$label;
        my $new_one = CM::Permutation->new(@new_perm);
        $res.="$label -> $new_one\n";
    };
    $res;
}

sub BUILD {
    my ($self) = @_;
    my $p = new Algorithm::Permute([1..$self->n]);
    my @permutations;
    my $label = 0;
    while (my @new_perm = $p->next) {
        my $new_one = CM::Permutation->new(@new_perm);
        $new_one->label(++$label);
        unshift @permutations,$new_one;
    };
    my $order = $self->order;
    for my $i (0..-1+$order) {
        for my $j (0..-1+$order) {
            $self->operation_table->[$i]->[$j] =
                $permutations[$i] * $permutations[$j];
            my $actual_label = 
                (   
                    first { $_ == $self->operation_table->[$i]->[$j] }
                        @permutations
                )->label;
            $self->operation_table->[$i]->[$j]->label($actual_label);
        }
    }
};

=pod

=head1 draw_cayley_digraph($path)

This method will draw the cayley digraph of the group to png to the given $path.

=head1 NOTES

Internally the permutations are stored in arrayref of arrayrefs and each cell contains a CM::Permutation object.

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

=pod

=head1 AUTHOR

Stefan Petrea, C<< <stefan.petrea at gmail.com> >>

=cut

1;
