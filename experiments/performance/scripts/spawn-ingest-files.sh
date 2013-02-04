#!/bin/bash -l

# Author: Lighton Phiri <lighton.phiri@gmail>
# http://lightonphiri.org
# 
# January 31, 2013
#
# A basic benchmarking script
# It basically makes use of ApacheBench simulating 1 concurrent users
# 

# 
##python -c "import dspacebenchmarks; dspacebenchmarks.rssresults('/home/phiri/Projects/masters/random/workload$structure/w$workload', $feedsize)";
for workload in `seq 1 12`
   do
      python -c "import dspacebenchmarks; dspacebenchmarks.dspacecsvfile('/home/phiri/Projects/masters/random/workload1/w$workload', 'w$workload', 1000, 'w$workload')";
   done
##python -c "import dspacebenchmarks; dspacebenchmarks.dspacecsvfile('/home/phiri/Projects/masters/random/workload1/w8', 'w8', 5000)";
