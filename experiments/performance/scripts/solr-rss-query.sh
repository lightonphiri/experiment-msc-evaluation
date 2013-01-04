#!/bin/bash -l

# Author: Lighton Phiri <lighton.phiri@gmail>
# http://lightonphiri.org
# 
# December 30, 2012
#
# A basic benchmarking script
# It basically makes use of ApacheBench simulating 1 concurrent users
# 

# 
for workload in `seq 1 15`
   do
      # start working
      echo " "
      echo "***** START Workload: $workload *****"
      echo " "

      for items in 5 10 20
         do
         echo " "
         echo "***** START Items: $items *****"
         echo http://localhost:8983/solr/w$workload/select?q=*:*\&fl=dc-identifier,dc-available\&sort=dc-available+desc\&rows=$items
         #ab -c 1 -n 5 -v 4 http://localhost:8983/solr/w$workload/select?q=*:*\&fl=dc-identifier,dc-available\&sort=dc-available+desc\&rows=$items
         ab -c 1 -n 1 -v 4 http://localhost:8983/solr/w$workload/select?q=*:*\&fl=dc-identifier,dc-available\&sort=dc-available+desc\&rows=$items

         #siege -c1 -r5 -d10 http://localhost:8983/solr/w$workload/select?q=*:*\&fl=dc-identifier,dc-title,dc-description,dc-available\&sort=dc-available+desc\&rows=$items
         echo " "
         echo "***** END Items: $items"
	 # pause for 5 seconds
         sleep 5
         done
      echo " "
      echo "***** END Workload $workload *****"
      echo " "
      # pause for 5 seconds
      sleep 5

   done
