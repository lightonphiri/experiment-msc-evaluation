# Points to note
# 1. URL encoding
# 2. 
# 

import datetime
import urllib # for urlencode function
import urllib2
from xml.dom.minidom import parseString

# function for return dom response after parsting oai-pmh URL
def oaipmh_response(URL):
  file = urllib2.urlopen(URL)
  data = file.read()
  file.close()
  
  dom = parseString(data)
  return dom

# function for getting value of resumptionToken after parsting oai-pmh URL
def oaipmh_resumptionToken(URL):
  file = urllib2.urlopen(URL)
  data = file.read()
  file.close()
  
  dom = parseString(data)
  print "START: "+str(datetime.datetime.now())
  return dom.getElementsByTagName('resumptionToken')[0].firstChild.nodeValue
  
# function for writing to output files
def write_xml_file(inputData, outputFile):
  oaipmhResponse = open(outputFile, mode="w")
  oaipmhResponse.write(inputData)
  oaipmhResponse.close()
  print "END: "+str(datetime.datetime.now())

baseURL = 'http://union.ndltd.org/OAI-PMH/'
getRecordsURL = str(baseURL+'?verb=ListRecords&metadataPrefix=oai_dc')

# initial parse phase
resumptionToken = oaipmh_resumptionToken(getRecordsURL) # get initial resumptionToken
print "Resumption Token: "+resumptionToken
outputFile = 'page-0.xml' # define initial file to use for writing response
write_xml_file(oaipmh_response(getRecordsURL).toxml(), outputFile)

# loop parse phase
pageCounter = 1
while resumptionToken != "":
  print "URL ECONDED TOKEN: "+resumptionToken
  resumptionToken = urllib.urlencode({'resumptionToken':resumptionToken}) # create resumptionToken URL parameter
  print "Resumption Token: "+resumptionToken
  getRecordsURLLoop = str(baseURL+'?verb=ListRecords&'+resumptionToken)
  oaipmhXML = oaipmh_response(getRecordsURLLoop).toxml()
  outputFile = 'page-'+str(pageCounter) # create file name to use for writing response
  write_xml_file(oaipmhXML, outputFile) # write response to output file
  
  resumptionToken = oaipmh_resumptionToken(getRecordsURLLoop)
  pageCounter += 1 # increament page counter