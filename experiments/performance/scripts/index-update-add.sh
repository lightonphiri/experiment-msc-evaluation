#!/bin/bash -l

# Author: Lighton Phiri <lighton.phiri@gmail>
# http://lightonphiri.org
# 
# January 5, 2013
#
# A basic benchmarking script
# It basically makes use of ApacheBench simulating 1 concurrent users
# 

python -c "import simplyctperformance; simplyctperformance.solrupdatesbatchmain('/home/phiri/Projects/masters/workload4')";
