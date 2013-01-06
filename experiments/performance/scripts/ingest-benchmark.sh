#!/bin/bash -l

# Author: Lighton Phiri <lighton.phiri@gmail>
# http://lightonphiri.org
# 
# January 5, 2013
#
# A basic benchmarking script
# It basically makes use of ApacheBench simulating 1 concurrent users
# 


# Guinea pig
ingestfile="/home/phiri/Projects/masters/workload4/w1/GEORGIA/oai-union.ndltd.org-GEORGIA--oai-digitalarchive.gsu.edu-chemistry_diss-1010.metadata"

for workload in `seq 1 15`
   do
      # start working
      echo " "
      echo "***** START Workload: $workload *****"
      echo " "

      for level in 1 2 3
         do
         archive="/home/phiri/Projects/masters/random/workload$level/w$workload"
         echo " "
         echo "***** START Levels: $level *****"
         for loopy in `seq 1 5`
            do
               # 
               echo w$workload,$level,$loopy,`python -c "import simplyctperformance; simplyctperformance.ingestitem('$ingestfile','$archive', $level)";`
               echo $archive
            done
         echo " "
         echo "***** END Levels: $level"
	 # pause for 10 seconds
         sleep 10
         done
      echo " "
      echo "***** END Workload $workload *****"
      echo " "
      # pause for 10 seconds
      sleep 10

   done
