#!/bin/bash

# Author: Lighton Phiri <lighton.phiri@gmail>
# http://lightonphiri.org
#
# A basic --and probably primitive-- benchmarking script
# It basically makes use of seige simulating 1 concurrent users
# 
# Basic siege configuration is in man pages
# A point to note is that .siegerc timeout value was changed to 3 hours
# because some requests take slightly longer than usual.
# 

# define OAI-PMH URL related variables
# 
appURL="http://localhost/OAI-XMLFile-2.21/XMLFile/"
FirstRecordset="oai.pl?verb=ListRecords&metadataPrefix=oai_dc"
LastRecordset="oai.pl?verb=ListRecords&resumptionToken=!!!oai_dc!"

# define arrays to hold first record and last record
# for each of the 15 workloads
# TODO: This is clearly primitive --automate assignment

# workload 1
wa[1]=90
wb[1]=0
wc[1]=0
# workload 2
wa[2]=190
wb[2]=100
wc[2]=0
# workload 3
wa[3]=390
wb[3]=300
wc[3]=0
# workload 4
wa[4]=790
wb[4]=700
wc[4]=0
# workload 5
wa[5]=1590
wb[5]=1500
wc[5]=1000
# workload 6
wa[6]=3190
wb[6]=3100
wc[6]=2000
# workload 7
wa[7]=6390
wb[7]=6300
wc[7]=5000
# workload 8
wa[8]=12790
wb[8]=12700
wc[8]=11000
# workload 9
wa[9]=25590
wb[9]=25500
wc[9]=24000
# workload 10
wa[10]=51190
wb[10]=51100
wc[10]=50000
# workload 11
wa[11]=102390
wb[11]=102300
wc[11]=101000
# workload 12
wa[12]=204790
wb[12]=204700
wc[12]=203000
# workload 13
wa[13]=409590
wb[13]=409500
wc[13]=408000
# workload 14
wa[14]=819190
wb[14]=819100
wc[14]=818000
# workload 15
wa[15]=1638390
wb[15]=1638300
wc[15]=1637000

# loop through the 15 workloads
for workload in `seq 1 15`
do

# dynamically generate archive workload
#archiveworkload="w2_"$workload
archiveworkload="w"$workload
baseURL=$appURL$archiveworkload"/"

# pull first and last records for contextual workload
resumptionTokenSize=${wc[$workload]}

# start working
echo " "
echo "***** START Workload $workload *****"
echo " "
echo "***ListRecords : First Recordset***"
echo $baseURL$FirstRecordset
siege -c1 -r5 -d5 $baseURL$FirstRecordset
echo "***ListRecords : Last Recordset***"
echo $baseURL$LastRecordset$resumptionTokenSize
siege -c1 -r5 -d5 $baseURL$LastRecordset$resumptionTokenSize
#echo "***ListIdentifiers***"
#echo $baseURL$ListIdentifiers
#siege -c1 -r5 -d5 $baseURL$ListIdentifiers
#echo "***ListSets***"
#echo $baseURL$ListSets
#siege -c1 -r5 -d5 $baseURL$ListSets
#echo "*** GetRecord -- First Record***"
#echo $baseURL$GetRecordFirst$firstRecord
#siege -c1 -r5 -d5 $baseURL$GetRecordFirst$firstRecord
#echo "*** GetRecord -- Last Record***"
#echo $baseURL$GetRecordLast$lastRecord
#siege -c1 -r5 -d5 $baseURL$GetRecordLast$lastRecord
echo " "
echo "***** END Workload $workload *****"
echo " "

done
