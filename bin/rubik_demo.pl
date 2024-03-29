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
# Thu 18 Feb 2010 06:14:49 PM EST
# Stefan Petrea 
#
# simulation of Rubik's cube using OpenGL
#
use lib './lib';
use Carp;
use Rubik::View;
use Rubik::Model;
use Time::HiRes qw(usleep);

use constant ESCAPE => 37;

=pod

=head1 NAME

rubik_demo.pl - just some moves made repeatedly to a rubik's cube


=head1 VERSION

version 0.94

=cut




my $view = Rubik::View->new();
my $model= Rubik::Model->new({view=>$view});

# all of the turns are 90 degrees
my @faces = qw/Fi U D/; # cyclic moves list
my $turnspeed = 3;
my $turnangle = 90;
my $iface=0; # face iterator

confess "turn speed must be an integer"            if(  $turnspeed != int($turnspeed));
confess "turn speed must divide $turnangle"    unless(  $turnangle % $turnspeed == 0);

$view->currentmove( $faces[$iface] ); # start with this face


print "ORDER:".($model->rubik->F * $model->rubik->R)->order."\n"; # order is 105

my $iter=0;



#$model->scramble; # make a random series of moves to scramble the cube
#       - add tests

$|=1;


$view->CustomDrawCode(
    sub {
        usleep(20000);
        #glRotatef(2,0,1,0); # rotate it while the moves are carried out
        $view->spin( $view->spin + $turnspeed );#need to take in account something where divisibility is not needed
        if(  $view->spin % $turnangle == 0) {
            $view->spin(0);
            $model->move($faces[$iface]);
            $iface = ($iface + 1) % @faces;
            $view->currentmove($faces[$iface]);
            print "Doing move $faces[$iface]\n";
        };
    }
);


$view->KeyboardCallback(
    sub {
        my ($self) = @_;
        # Shift the unsigned char key, and the x,y placement off @_, in
        # that order.
        my ($key, $x, $y) = @_;

        if ($key == ord('f')) {

            # Use reshape window, which undoes fullscreen
            glutReshapeWindow(640, 480);
        }

        if ($key == ESCAPE) 
        { 
            glutDestroyWindow($self->glWindow); 

            exit(0);                   
        };
    }
);




$view->Init;
