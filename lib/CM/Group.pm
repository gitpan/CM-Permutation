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
package CM::Group;
{
  $CM::Group::VERSION = '0.94';
}
use Moose::Util q/apply_all_roles/;
use MooseX::Role::Parameterized;
use Acme::AsciiArt2HtmlTable;
use Math::Polynomial;
use List::AllUtils qw/all first zip uniq/;
use Carp;
use GraphViz;
use Text::Table;
use CM::Tuple;
use strict;
use warnings;
requires '_builder_order';
requires '_compute_elements';
requires 'operation'; # wrapper function over operation of elements , REM : whenever I do  * in a group method
                      # I should replace that with  $self->operation($arg1,$arg2)
parameter 'element_type' => ( isa   => 'Str' );



=head1 NAME

CM::Group - A parametrized role to abstract the characteristics of a group.


=head1 VERSION

version 0.94

=head1 DESCRIPTION

This role will describe the general characteristics of a Group, its attributes, and as much as
can be abstracted from the current implementation.

This role will be instantiated with the parameter element_type being the type of the elements that the group
will contain.

=head1 SYNOPSIS


    pacakge SomeGroup;
    use Moose;
    with 'CM::Group' => { element_type => 'GroupElement'  };
    
    sub _builder_order {
      # order of the group is computed here
    }
    sub compute_elements {
      # the elements are computed here
    }
    sub operation { 
      # group operation is defined here (it's usually a wrapper of the "*" operator of GroupElement)
    }


=head1 AUTHOR

Stefan Petrea, C<< <stefan.petrea at gmail.com> >>

=cut



# parametrized roles are a lot like C++ templates, 
# update Wed Mar 10 06:17:44 2010 -> except they're not C++ templates and Perl is not C++

role {
    my $p = shift;

    my %args = @_;
    my $consumer = $args{consumer};

	has compute_elements => (
		isa	=> 'CodeRef',
		is	=> 'rw',
        builder => '_compute_elements',
	);

    my $T = $p->element_type;

    has n => (              # this will be related to the order of the group
        isa      => 'Int',
        is       => 'rw',
        default  => undef,
        required => 1,
    );


    # only used for assigning labels
    has tlabel  => (
	    isa     => 'Int',
	    is      => 'rw',
	    default => 1,
	    lazy    => 1,
    );

    has order   => (
        isa     => 'Int',
        is      => 'rw',
        lazy    => 1,
        builder => '_builder_order',
    );

    has operation_table => (
        isa             => "ArrayRef[ArrayRef[$T]]",
        is              => 'rw',
        default         => sub{[]},
    );

    has elements => (
        isa      => "ArrayRef[$T]",
        is       => 'rw',
        default  => sub {[]},
    );

    has computed => (
        isa      => "Bool",
        is       => 'rw',
        default  => 0,
    );

    # generating polynomial of group
    # Adventures in Group Theory - David Joyner 2nd edition
    method gen_polynomial => sub {
        my ($self) = @_;
        my @coeffs;
        $coeffs[$_->[0]->order()]++
            for $self->conj_classes_fast(); # count number of elements of different orders from each conj class
                                        # (in a conjugacy class every element has the same order)
        return Math::Polynomial->new( 0 , @coeffs );
    };

    method add_to_elements => sub {
        my ($self,$newone) = @_;


	$newone->label($self->tlabel);
        unshift @{$self->elements},$newone;

        croak "not all elements have labels"
        unless( all { defined($_->label) }(@{ $self->elements }) );

	$self->tlabel($self->tlabel + 1);

    };

    method perm2label => sub {
        my ($self,$perm) = @_;
        my $found = first { 
            $_ == $perm;
        } @{$self->elements};

        return $found->label;
    };

    method label2perm => sub { };

    method cayley_digraph => sub {
        my ($self,$path,$generators) = @_;
        my $graph = GraphViz->new(
            center   => 1 ,
            ratio    => 'fill',
            width    => 9,
            height   => 9,
            layout   => 'fdp',
            directed => 0,
        );
        my @seen;
        my @colors = qw/green blue yellow/; # will need to add more colors (maybe 10 should suffice, for my needs I won't try to generate stuff with more than 10 generators)

        my %color = zip(@$generators,@colors);

        for my $x (@{$self->elements}) {
            my $from = $x;
            for my $g (@$generators) {
                my $to   = $self->operation($x,$g);
                next if "$from,$to" ~~ @seen;
                $graph->add_edge(
                    "$from"   => "$to",
                    label     => "$g",
                    color     => $color{"$g"},
                    fontcolor => $color{"$g"},
                    style     => "setlinewidth(1.8)",
                );
                push @seen,"$from,$to";
                push @seen,"$to,$from";
            }
        };
        $graph->as_gif($path // "/var/www/docs/graph.gif");
    };

    method draw_diagram => sub {
        my ($self,$path) = @_;
        my $order = $self->order;
        my $graph = GraphViz->new(
            center => 1 ,
            ratio  => 'fill',
            width  => 30,
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
    };


# TODO: same thing as with compute, need to use Data::Alias for locals

# rearrange so that the identity element is always on the first diagonal

    method rearrange => sub {
        my ($self) = @_;
        my $order = $self->order;
        for my $y ( 0..-1+$order) {
            my $c = -1; #the column on which the identity sits on row $y

            local *ycol = \$self->operation_table->[$y];

            #identity element already in place so we skip this
            next if( ${*ycol}->[$y] == $self->identity);

            for my $x (0..-1+$order) {
                if( ${*ycol}->[$x] == $self->identity ) {
                    $c = $x;
                    last;
                };
            };


            #now swap the identity column with the column it should be on but only if needed
            my $tmp = ${*ycol};
            ${*ycol} = $self->operation_table->[$c];
            $self->operation_table->[$c] = $tmp;
        }
    };

    method draw_asciitable => sub {
         # this module shouldn't be in Acme namespace.. it's pretty useful
         #my $g = CM::Group::Sym->new({n=>4});

        my ($self,$file) = @_;

        my $alpha = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
        $self->compute unless $self->computed;

        $self->rearrange; # rearrange elements so identity sits on first diagonal so we can see the symmetries properly

        my $table = "$self";

        print "$table\n";
        
        # the identity element needs to be on the first diagonal if we're going to make any sense out of this

        $table =~ s/(\d+)/substr($alpha,$1,1)/ge;
        $table =~ s/( )+//g; # get spaces out of the way

        my $html = aa2ht( { 
                            'randomize-new-colors' => 1 ,
                            'td'                   => 
                                                    {
                                                    'width'  => '20px',
                                                    'height' => '20px'
                                                    }
                          }, $table);

        open my $fh,">$file";

        print $fh $html;
    };

    method compute => sub {
        my ($self) = @_;

        return $self if $self->computed;

        $self->compute_elements()->();

        print "number of elements".scalar(@{$self->elements})."\n";

        croak "not all elements are defined"
        unless( all { defined($_) }(@{ $self->elements }) );


        # TODO: the locals need to be fixed using Data::Alias...
        my $order = $self->order;
        # *ij is actually an alias(typeglob) to $self->operation_table->[$i]->[$j]
        for my $i (0..-1+$order) {
            for my $j (0..-1+$order) {
                local *i  = \$self->elements->[$i];
                local *j  = \$self->elements->[$j];
                local *ij = \$self->operation_table->[$i]->[$j];

                croak "one of multiplication arguments is undefined $i  $j"
                unless defined(${*i}) && defined(${*j});


                ${*ij} = $self->operation(${*i},${*j});

                croak "result is undefined"
                unless defined(${*ij}); 
                ${*ij}->label($self->perm2label(${*ij}));
            }
        };
        $self->computed(1); # mark it as being computed

        return $self; # to be able to chain
    };

	# checks to see if a group is abelian or not
	method abelian => sub {
		my ($self) = @_;
		# double not because we're not interested in the actual element, instead
		# we just want to know if there is at least one breaking commutativity

		my ($a,$b);

		for my $a (@{$self->elements}) {
			for my $b (@{$self->elements}) {
				if($a*$b!=$b*$a) {
					print "$a\n$b\n";
					exit;
				};
			}
		};
		1;
	};

	method normal => sub {
		my ($G,$N) = @_;
		# basically just checks if each right coset is equal to the right coset
		my $H;
		my $res = 1;
		for my $x ( @{ $G->elements } ) {
			my @left_coset  = map { $x * $_ } @{$N->elements};
			my @right_coset = map { $_ * $x } @{$N->elements};
			my $H;
			$H->{"$_"} = 1
			for @left_coset;
			$res &= $H->{"$_"} 
			for @right_coset;
			# have checked if left_coset and right_coset basically contain the same elements
		};
		return $res;
	};


    # this will return a commutator group
	# (create a new group with the same type of elements as $self and just compute all the commutators
	# put them in the group, mock up the compute_elements code ref and that's about it)
    method commutator => sub {
	    my ($self) = @_;
		my $com_group = $self->meta->name->new({n=>$self->n});

		my @elements=
		uniq
	    map {
		    my $p = $_;
		    map {
				$p->com($_); 
				#com does not always exist(as per implementation) as a method for the object(need to check if it has it defined)
				#maybe the role CM::Group can check if there's a ->com for elements before composing
		    } @{$self->elements};
	    } @{$self->elements};


		$com_group->add_to_elements($_)
		for @elements;

		$com_group->order(~~@elements); # another ideea would've been to make _build_order like _compute_elements
										# and replace that here

		#$com_group->elements(\@elements);
		$com_group->compute_elements(sub{});

		return $com_group;
    };

    method stringify => sub {
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
    };


	# implemented the factor group, computed elements
	# TODO: write code for choosing representants
	#       this method should return a group
	method factor => sub { # G/N
		# the problem is choosing the right representatives for the equivalence classes
		my ($G,$N) = @_;

		#confess 'can only factor with group that\'s normal' unless $N->normal($G);
		my $group = $G->meta->name->new({n=>$G->n});

		my @all	= @{$G->elements};
		my @classes;

		while(@all) {
			# take first element, build a coset, take that coset out , repeat..
			my @new = map { $all[0] * $_  } @{$N->elements};# a new class

			push @classes,\@new;
			
			
			my @alln; # alln = all - new
			
			for my $a (@all) {
				my $found;
				for my $n (@new) {
					if($a == $n) {
						$found=1;
						last;
					};
				};
				push @alln,$a if !$found;
			};
			
			@all = @alln;
		};

		# here we should have all classes of equivalence we need
		# which are the actual elements of the factor group

		return \@classes;
	};
    
#    method group_product => sub {
#	    my ($G,$H) = @_;
#	    return {};
#    };

    #cartesian product of 2 groups
};

1;
