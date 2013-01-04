#!/usr/bin/python

import simplyctperformance

#simplyctperformance.solrupdatesbatchmain('/home/phiri/Projects/masters/workload3')
for loops in range(1,6):
	print "ITERATION: ", loops
	simplyctperformance.solrupdatesbatchmain('/home/phiri/Projects/masters/workload3')
	print "ITERATION: ", loops
	
