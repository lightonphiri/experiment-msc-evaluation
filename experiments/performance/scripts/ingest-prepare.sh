#!/bin/bash -l

# Author: Lighton Phiri <lighton.phiri@gmail>
# http://lightonphiri.org
# 
# January 5, 2013
#
# A basic benchmarking script
# It basically pre-creates container objects for ingest benchmarks
# 

for workload in `seq 1 15`
   do
      file /home/phiri/Projects/masters/random/workload1/w$workload/GEORGIA
      #mkdir -p /home/phiri/Projects/masters/random/workload1/w$workload/GEORGIA
      file /home/phiri/Projects/masters/random/workload2/w$workload/GEORGIA/2007
      #mkdir -p /home/phiri/Projects/masters/random/workload2/w$workload/GEORGIA/2007
      file  /home/phiri/Projects/masters/random/workload3/w$workload/GEORGIA/2007/b
      #mkdir -p /home/phiri/Projects/masters/random/workload3/w$workload/GEORGIA/2007/b
   done
