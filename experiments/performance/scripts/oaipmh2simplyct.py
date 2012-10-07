# A module that creates a simplyct archive using an oaipmh response output as input

import os
import xml
from xml.dom.minidom import parse, parseString

def oaipmh2simplyctparser(inputfile):
  oaipmhdom = parse(inputfile) # parse xml file
  for record in oaipmhdom.getElementsByTagName('record'):
    # get dc:identifier for filename
    #identifier = str((record.getElementsByTagName('dc:identifier')[0].firstChild.data)[(record.getElementsByTagName('dc:identifier')[0].firstChild.data).index('://')+3:])
    identifier = record.getElementsByTagName('identifier')[0].firstChild.data
    print "Identifier is: ", identifier
    identifier = identifier.replace("/", "--") # replace "/" with single hyphen
    identifier = identifier.replace(":", "-") # replace : with single hyphen
    # get setSpec for base container name
    container = record.getElementsByTagName('setSpec')[0].firstChild.data
    # xml chunking
    try:
      print "Processing record: ", record.getElementsByTagName('identifier')[0].firstChild.data
      xmldocument = parseString(record.toxml())
      print "End Processing ..."
    except xml.parsers.expat.ExpatError as details:
      print "Error Handling: ", details
    # call function for writing xmldocument
    container = '../data/archive/' + container
    identifier = identifier + '.metadata'
    simplyctwriter(xmldocument.toxml(), container, identifier)
    
def simplyctwriter(xmldata, directory, filename):
  # handle potentially malformed xml content
  xmldata = str(xmldata).encode('ascii', 'ignore')
  # construct path to write output to
  if not os.path.exists(directory):
    os.makedirs(directory)
  xmlwriter = open(os.path.join(directory, filename), mode='w')
  xmlwriter.write(xmldata)
  xmlwriter.close()