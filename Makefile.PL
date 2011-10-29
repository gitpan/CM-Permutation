
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Module for manipulating permutations ",
  "AUTHOR" => "Stefan Petrea <randomcoder1\@gmail.com>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "CM-Permutation",
  "EXE_FILES" => [
    "bin/rubik_demo.pl",
    "bin/rubik_game.pl"
  ],
  "LICENSE" => "perl",
  "NAME" => "CM::Permutation",
  "PREREQ_PM" => {
    "Acme::AsciiArt2HtmlTable" => 0,
    "Algorithm::Permute" => 0,
    "Bit::Vector" => "7.1",
    "Carp" => 0,
    "Devel::REPL" => "1.003009",
    "GD::SVG" => "0.33",
    "GraphViz" => 0,
    "List::AllUtils" => "0.02",
    "Math::BigInt" => 0,
    "Math::Complex" => "1.56",
    "Math::Factor::XS" => "0.38",
    "Math::Pari" => "2.01080605",
    "Math::Polynomial" => "1.002",
    "Math::Polynomial::Solve" => "2.50",
    "Math::Primality" => "0.04",
    "Math::Prime::XS" => "0.23",
    "Math::Symbolic" => "0.606",
    "Moose" => "0.92",
    "MooseX::Role::Parameterized" => "0.17",
    "OpenGL" => "0.64",
    "PDL" => "2.4.6",
    "Params::Validate" => "0.94",
    "Storable" => 0,
    "Test::Deep" => "0.106",
    "Test::More" => 0,
    "Text::Table" => "1.114",
    "overload" => 0
  },
  "VERSION" => "0.94",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



