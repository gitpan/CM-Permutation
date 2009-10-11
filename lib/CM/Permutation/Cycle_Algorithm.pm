package CM::Permutation::Cycle_Algorithm;
use Moose;
use List::AllUtils qw/first/;
extends 'CM::Permutation';

has marked => (
    isa => 'ArrayRef[Bool]',
    is  => 'rw',
    default => sub {[]},
);

has cycles   => (
    isa => 'ArrayRef[ArrayRef[Int]]',
    is  => 'rw',
    default => sub {[]},
);

sub get_first_unmarked {
    my ($self)=@_;
    return first {
        !$self->marked->[$_]
    } 1..-1+@{$self->perm};
}

sub uncover_cycle {
    my ($self,$start) = @_;
    warn "already uncovered" if $self->marked->[$start];
    my $current = $start;
    my $new_cycle = [];
    while(1) {
        $current = $self->perm->[$current];
        $self->marked->[$current] = 1;
        push @$new_cycle,$current;
        last if $current == $start;
    };
    push @{$self->cycles},$new_cycle;
}

sub run {
    my ($self,$start) = @_;
    while(my $unmarked = $self->get_first_unmarked) {
        $self->uncover_cycle($unmarked);
    };
}

sub str_decomposed {
    my ($self) = @_;
    my $rep =
    join
    ('*',
        (
            map {
                my $str = join(',',@{$_});
                "($str)";
            } @{$self->cycles}
        )
    );
    $rep;
}


1;
