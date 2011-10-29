#!/bin/bash
rm -rf nytprof*
perl -d:NYTProf -Ilib t/*.t
nytprofhtml
google-chrome ./nytprof/index.html

