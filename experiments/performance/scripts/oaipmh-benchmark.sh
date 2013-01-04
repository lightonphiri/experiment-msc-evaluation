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
ListRecords="oai.pl?verb=ListRecords&metadataPrefix=oai_dc"
ListIdentifiers="oai.pl?verb=ListIdentifiers&metadataPrefix=oai_dc"
ListSets="oai.pl?verb=ListSets"
GetRecordFirst="oai.pl?verb=GetRecord&metadataPrefix=oai_dc&identifier="
GetRecordLast="oai.pl?verb=GetRecord&metadataPrefix=oai_dc&identifier="

# define arrays to hold first record and last record
# for each of the 15 workloads
# TODO: This is clearly primitive --automate assignment

# workload 1
wa[1]=oai-union.ndltd.org-TW--090NCU05015040.metadata
wb[1]=oai-union.ndltd.org-TW--090NTNU0395018.metadata
# workload 2
wa[2]=oai-union.ndltd.org-TW--090NCHU0402007.metadata
wb[2]=oai-union.ndltd.org-TW--090NTNU0395018.metadata
# workload 3
wa[3]=oai-union.ndltd.org-TW--100FJU00023021.metadata
wb[3]=oai-union.ndltd.org-TW--090NCTU0489014.metadata
# workload 4
wa[4]=oai-union.ndltd.org-TW--090NCTU0435042.metadata
wb[4]=oai-union.ndltd.org-TW--090NCTU0423012.metadata
# workload 5
wa[5]=oai-union.ndltd.org-TW--090NCTU0435090.metadata
wb[5]=oai-union.ndltd.org-TW--090NCTU0423012.metadata
# workload 6
wa[6]=oai-union.ndltd.org-TW--090NCTU0435090.metadata
wb[6]=oai-union.ndltd.org-TW--100ISU00731008.metadata
# workload 7
wa[7]=oai-union.ndltd.org-UMASS--oai-scholarworks.umass.edu-dissertations-4743.metadata
wb[7]=oai-union.ndltd.org-TW--100ISU00731008.metadata
# workload 8
wa[8]=oai-union.ndltd.org-UMASS--oai-scholarworks.umass.edu-theses-1790.metadata
wb[8]=oai-union.ndltd.org-TW--100ISU00731008.metadata
# workload 9
wa[9]=oai-union.ndltd.org-MONTANA--oai-etd.lib.umt.edu-etd-05272008-134949.metadata
wb[9]=oai-union.ndltd.org-TW--100ISU00731008.metadata
# workload 10
wa[10]=oai-union.ndltd.org-UHAWAII--oai-scholarspace.manoa.hawaii.edu-10125--10382.metadata
wb[10]=oai-union.ndltd.org-CHENGCHI--B2002008312.metadata
# workload 11
wa[11]=oai-union.ndltd.org-UHAWAII--oai-scholarspace.manoa.hawaii.edu-10125--10382.metadata
wb[11]=oai-union.ndltd.org-CHENGCHI--B2002008312.metadata
# workload 12
wa[12]=oai-union.ndltd.org-TDX_URL--oai-www.tdx.cat-10803--9200.metadata
wb[12]=oai-union.ndltd.org-CHENGCHI--B2002008312.metadata
# workload 13
wa[13]=oai-union.ndltd.org-TDX_URL--oai-www.tdx.cat-10803--9200.metadata
wb[13]=oai-union.ndltd.org-CHENGCHI--B2002008312.metadata
# workload 14
wa[14]=oai-union.ndltd.org-ADTP--255700.metadata
wb[14]=oai-union.ndltd.org-CHENGCHI--B2002008312.metadata
# workload 15
wa[15]=oai-union.ndltd.org-ADTP--255700.metadata
wb[15]=oai-union.ndltd.org-CHENGCHI--B2002008312.metadata

# loop through the 15 workloads
for workload in `seq 1 15`
do

# dynamically generate archive workload
#archiveworkload="w2_"$workload
archiveworkload="w"$workload
baseURL=$appURL$archiveworkload"/"

# pull first and last records for contextual workload
firstRecord=${wa[$workload]}
lastRecord=${wb[$workload]}

# start working
echo " "
echo "***** START Workload $workload *****"
echo " "
echo "***ListRecords***"
echo $baseURL$ListRecords
siege -c1 -r5 -d5 $baseURL$ListRecords
echo "***ListIdentifiers***"
echo $baseURL$ListIdentifiers
siege -c1 -r5 -d5 $baseURL$ListIdentifiers
echo "***ListSets***"
echo $baseURL$ListSets
siege -c1 -r5 -d5 $baseURL$ListSets
echo "*** GetRecord -- First Record***"
echo $baseURL$GetRecordFirst$firstRecord
siege -c1 -r5 -d5 $baseURL$GetRecordFirst$firstRecord
echo "*** GetRecord -- Last Record***"
echo $baseURL$GetRecordLast$lastRecord
siege -c1 -r5 -d5 $baseURL$GetRecordLast$lastRecord
echo " "
echo "***** END Workload $workload *****"
echo " "

done
