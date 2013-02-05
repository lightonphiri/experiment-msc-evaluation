#!/bin/bash -l

# Author: Lighton Phiri <lighton.phiri@gmail>
# http://lightonphiri.org
# 
# February 1, 2013
#
# A basic DSpace ingest script
# It basically makes use of DSpace's metadata-import utility to 
# ingest 1k batch files for specified workloads
# 

# 
for workload in `seq 1 12`
do
echo "START WORKLOAD|w$workload|`date`"
for loopy in `seq 1 5`
do
echo "Looping #$loopy"
# copy server.xml file
##sudo cp /etc/tomcat6/w$workload-server.xml /etc/tomcat6/server.xml
###sudo cp /etc/tomcat6/xserver.xml /etc/tomcat6/server.xml
# restart tomcat
sudo invoke-rc.d tomcat6 restart
sleep 30
# issue solr search query
##echo w$workload,$loopy,`python -c "import simplyctperformance; simplyctperformance.solrresponsehead(simplyctperformance.solrselectquery('http://localhost:8080/repo/solr/search/', 'thesis'))";`
echo w$workload,`python -c "import simplyctperformance; simplyctperformance.solrresponsehead(simplyctperformance.solrselectquery('http://localhost:8080/w$workload/solr/search/', 'thesis'))";`
##sh /usr/local/dspace/bin/dspace oai import
# script
echo "Looping #$loopy"
done
echo "END WORKLOAD|w$workload|`date`"
done
