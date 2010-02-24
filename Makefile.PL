use 5.010000;
use strict;
use warnings;



use ExtUtils::MakeMaker 6.11;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'CM::Permutation',
                       'DISTNAME' => 'CM-Permutation',
                       'AUTHOR' => 'Stefan Petrea <stefan.petrea@gmail.com>',
                       'ABSTRACT' => 'Module for manipulating permutations ',
                       'EXE_FILES' => [],
                       'VERSION' => '0.4',
                       'LICENSE' => 'perl',
                       'PREREQ_PM' => {
                                        'Text::Table' => '1.114',
                                        'Storable' => '0',
                                        'Acme::AsciiArt2HtmlTable' => '0',
                                        'Algorithm::Permute' => '0',
                                        'Bit::Vector' => '7.1',
                                        'Math::BigInt' => '0',
                                        'GraphViz' => '0',
                                        'Test::Deep' => '0.106',
                                        'Moose' => '0.92',
                                        'ExtUtils::MakeMaker' => '6.11',
                                        'List::AllUtils' => '0.02',
                                        'overload' => '0',
                                        'Carp' => '0',
                                        'Test::More' => '0',
                                        'Math::Polynomial' => '1.002',
                                        'Params::Validate' => '0.94',
                                        'OpenGL' => '0.62',
                                        'MooseX::Role::Parameterized' => '0.17'
                                      }
                     );


delete $WriteMakefileArgs{LICENSE}
  unless eval { ExtUtils::MakeMaker->VERSION(6.31) };

WriteMakefile(%WriteMakefileArgs);



