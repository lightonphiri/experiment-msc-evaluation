# A module that creates a simplyct archive using an oaipmh response output as input
import os
import time
import xml
from xml.dom.minidom import parse, parseString
import fileRSS2generator

def oaipmh2simplyctparser(inputfile):
  #print "START: PREPROCESSING[PARSING]: ", time.time()
  oaipmhdom = parse(inputfile) # parse xml file
  for record in oaipmhdom.getElementsByTagName('record'):
    # get dc:identifier for filename
    #identifier = str((record.getElementsByTagName('dc:identifier')[0].firstChild.data)[(record.getElementsByTagName('dc:identifier')[0].firstChild.data).index('://')+3:])
    identifier = record.getElementsByTagName('identifier')[0].firstChild.data
    #print "Identifier is: ", identifier
    identifier = identifier.replace("/", "--") # replace "/" with single hyphen
    identifier = identifier.replace(":", "-") # replace : with single hyphen
    identifier = identifier + '.metadata'
    # get setSpec for base container name
    container = record.getElementsByTagName('setSpec')[0].firstChild.data
    container = '../RSS2feeds2/' + container
    # xml chunking
    try:
      #print "Processing record: ", record.getElementsByTagName('identifier')[0].firstChild.data
      xmldocument = parseString(record.toxml())
      simplyctwriter(xmldocument.toxml(), container, identifier)
      #print "End Processing ..."
    except xml.parsers.expat.ExpatError as details:
      pass
      #print "Error Handling: ", details
    # call function for writing xmldocument
    #container = '../RSS2feeds2/' + container
    #identifier = identifier + '.metadata'
    #print "END: PREPROCESSING[PARSING]: ", time.time()
    #simplyctwriter(xmldocument.toxml(), container, identifier)
    # start calling functions in fileRSS2generator module
    archivedir = '/home/lphiri/datasets/ndltd/RSS2feeds2'
    # update index file
    fileRSS2generator.rssindex(record)
    # read index file to get a list of filies for rss feed generator function
    rss2indexlist = []
    with open('/home/lphiri/datasets/ndltd/scripts/index/RSS2-index.dat') as indexentries:
      for indexentry in indexentries:
	(key, values) = indexentry.split('|')
        rss2indexlist.append(key)
    # generate rss feed
    print rss2indexlist
    fileRSS2generator.writeRSS2file(rss2indexlist)
    # feed writeRSS2file function with output from rssindex function -- taking note that input is text file with pipe seperated entries
    #fileRSS2generator.writeRSS2file(fileRSS2generator.recentfiles(archivedir))
    
def simplyctwriter(xmldata, directory, filename):
  #print "START: PREPROCESSING[WRITING]: ", time.time()
  # handle potentially malformed xml content
  xmldata = str(xmldata).encode('ascii', 'ignore')
  # construct path to write output to
  if not os.path.exists(directory):
    os.makedirs(directory)
  xmlwriter = open(os.path.join(directory, filename), mode='w')
  xmlwriter.write(xmldata)
  xmlwriter.close()
  #print "END: PREPROCESSING[WRITING]: ", time.time()
