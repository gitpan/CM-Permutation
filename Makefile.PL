use 5.010000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'CM::Permutation',
    VERSION_FROM      => 'lib/CM/Permutation.pm', # finds $VERSION
    PREREQ_PM         => {
        'List::AllUtils'    => 0,
        'Moose'             => 0,
        'Algorithm::Permute'=> 0,
        'GraphViz'          => 0,
        'Test::More'        => 0,
        'Test::More'        => 0,
        'Text::Table'       => 0,
        'Carp'              => 0,
        'Storable'          => 0,
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/CM/Permutation.pm', # retrieve abstract from module
       AUTHOR         => 'Stefan Petrea <stefan.petrea@gmail.com>') : ()),
);
