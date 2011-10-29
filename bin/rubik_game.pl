#!/usr/bin/env perl
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
#
# rubik's cube game
#
use Data::Dumper;
use Carp;
use lib './lib';
use Rubik::View;
use Rubik::Model;
use Time::HiRes qw(usleep);
use List::AllUtils qw/any/;
use feature ':5.10';

=pod

=head1 NAME

rubik_game.pl - Rubik's cube game

=head1 VERSION

version 0.94

Use S to scramble the cube.

Use F(ront),B(ack),U(p),D(own),L(eft),R(ight) to move the cube.

=cut

my $view = Rubik::View->new();
my $model= Rubik::Model->new({view=>$view});

#TODO: All controller logic needs to be moved to CM::Rubik::Controller

my $turnspeed = 3;
my $turnangle = 90;

confess "turn speed must be an integer"            if(  $turnspeed != int($turnspeed));
confess "turn speed must divide $turnangle"    unless(  $turnangle % $turnspeed == 0);


$|=1;


my @move_buffer;
my $move_lock = 0;
my $move_current = 0;


$view->CustomDrawCode(
    sub {
        usleep(2000);

        if($view->spin == 0) {
            if(@move_buffer > 0) {
                $move_lock = 1;
                my $new_key = shift @move_buffer;

                given($new_key) {
                    when('S'){ $model->scramble; return;  }
                    when('Z'){ $model->reset;    return;  }
                    default  {}
                };



                $view->currentmove($new_key);
                #taking view out of the state $view->spin==0, on next execution of this sub it will
                #go on the else{} branch
                $view->spin( $view->spin + $turnspeed );
            };
        } elsif($view->spin == $turnangle) {
            #$model->move permutes the visible faces of the cubies w.r.t. the new configuration
            #after the rotation
            $model->move($view->currentmove);
            $view->spin(0);
            $move_lock = 0;
        } else {
            if($move_lock){
                #say "increase spin!";
                #say "spin=".$view->spin;
                $view->spin( $view->spin + $turnspeed );
            };
        };

    }
);

$view->KeyboardCallback(
    sub {
        my ($key, $x, $y) = @_;

        my @allowed_keys = map { ord $_ } split //,"furbldsz";

        #print Dumper \@allowed_moves;
        #print Dumper \$key;

        if( any { $key == $_ } @allowed_keys ) {
            #print "$key\n";
            push @move_buffer, uc(chr($key));
        };
    }
);

$view->MouseMoveCallback(
  sub {
    my ($x,$y) = @_;
    #print Dumper \@_;
    
    $ydiff = $y - $view->mouse_pos->[1];
    $xdiff = $x - $view->mouse_pos->[0];




    my $num = int($view->view_angles->[0]/90) % 4;
    printf "y -> %d , revert -> %d\n" , $view->view_angles->[0],($num == 1 || $num == 2);

    # The ternary operator expression is trying to account for reverting Ox movements when cube is upside down
    # still a bit buggy..

    $view->view_angles->[1] += ( $num == 1 || $num == 2  ? -1 : +1 ) * $xdiff;
    $view->view_angles->[0] += $ydiff;



    @{$view->mouse_pos} = @_;
  }
);

$view->MouseClickCallback(
  sub {
    given("$_[0]$_[1]") {
      when("00") {

      }
      when("01") {

      }
      default {
      }
    };
  }
);


$view->Init;
