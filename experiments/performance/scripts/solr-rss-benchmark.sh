#!/bin/bash -l

# Author: Lighton Phiri <lighton.phiri@gmail>
# http://lightonphiri.org
# 
# January 4, 2013
#
# A basic benchmarking script
# It basically makes use of ApacheBench simulating 1 concurrent users
# 

# 
for workload in `seq 1 15`
   do
      # start working
      coreurl=http://localhost:8983/solr/w$workload/
      echo $coreurl
      echo " "
      echo "***** START Workload: $workload *****"
      echo " "

      for items in 5 10 20
         do
         selectquery="*:*&rows=$items"
         echo " "
         echo "***** START Items: $items *****"
         #echo http://localhost:8983/solr/w$workload/select?q=*:*\&fl=dc-identifier,dc-available\&sort=dc-available+desc\&rows=$items
         for loopy in `seq 1 5`
            do
               # logfile
               solrlogfile=nohup-solrrss-$workload$items$loopy.txt
               # very crude and primitive *SMDH* --kill Solr process
               kill `ps -ef | grep Dsolr | awk '{if (NR==1) print $2}'`
               sleep 20
               # take Solr for a spin --again
               cd /home/phiri/Projects/masters/ndltd-solr/apache-solr-random/example
               nohup java -Dsolr.solr.home=/home/phiri/Projects/masters/ndltd-solr/apache-solr-random/example/example-DIH/solr -jar /home/phiri/Projects/masters/ndltd-solr/apache-solr-random/example/start.jar > $solrlogfile &
               # send workhorse to sleep to allow Solr to initialise
               # time was arrived at after a series of bench to determine how long Solr takes to initialise
               sleep 20
               # call python module functions
               # make sure working directory is launchpad --script directory
               cd /home/phiri/Projects/masters/scripts
               echo w$workload,$items,$loopy,`python -c "import simplyctperformance; simplyctperformance.solrresponsehead(simplyctperformance.solrselectquery('$coreurl', '$selectquery'))";`
               #echo nohup-$workload-$items-$loopy.txt
               #echo $coreurl$selectquery
               ##echo $solrlogfile
            done
         echo " "
         echo "***** END Items: $items"
	 # pause for 5 seconds
         #sleep 5
         done
      echo " "
      echo "***** END Workload $workload *****"
      echo " "
      # pause for 5 seconds
      #sleep 5

   done
