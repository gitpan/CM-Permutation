use 5.010000;
use strict;
use warnings;



use ExtUtils::MakeMaker;

WriteMakefile(
  DISTNAME  => 'CM-Permutation',
  NAME      => 'CM::Permutation',
  AUTHOR    => "Stefan\ Petrea\ \<stefan\.petrea\@gmail\.com\>",
  ABSTRACT  => "Module\ for\ manipulating\ permutations\ ",
  VERSION   => '0.065',
  EXE_FILES => [ qw() ],
  (eval { ExtUtils::MakeMaker->VERSION(6.31) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM    => {
    "Text::Table" => '0',
    "List::AllUtils" => '0',
    "Storable" => '0',
    "Algorithm::Permute" => '0',
    "Carp" => '0',
    "Test::More" => '0',
    "Math::BigInt" => '0',
    "GraphViz" => '0',
    "Test::Deep" => '0',
    "Moose" => '0',
  },
  test => {TESTS => 't/*.t'}
);

