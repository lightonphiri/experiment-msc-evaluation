#!/bin/bash -l

# Author: Lighton Phiri <lighton.phiri@gmail>
# http://lightonphiri.org
# 
# January 15, 2012
#
# A basic benchmarking script
# It basically makes use of ApacheBench simulating 1 concurrent users
# 

# 
for phrase in thesis university
do
echo " "
echo "***** START Search: $phrase *****"
echo " "
for structure in 1 2 3
   do
      # start working
      echo " "
      echo "***** START Structure: $structure *****"
      echo " "

      for workload in `seq 1 15`
         do
         echo " "
         echo "***** START Workload: $workload *****"
         for loopy in `seq 1 5`
            do 
               #echo $phrase,$structure,w$workload,$loopy
               echo s$phrase,h$structure,w$workload,l$loopy,`python -c "import simplyctperformance; simplyctperformance.searchresult(simplyctperformance.searchbasicbarrow('/home/phiri/Projects/masters/random/workload$structure/w$workload', '$phrase'))";`
               # pause for 10 seconds
               sleep 10
            done
         echo " "
         echo "***** END Workload: $workload"
	 # pause for 10 seconds
         sleep 10
         done
      echo " "
      echo "***** END Structure: $structure *****"
      echo " "
      # pause for 10 seconds
      sleep 10
   done
echo "***** END Search: $phrase *****"
done
