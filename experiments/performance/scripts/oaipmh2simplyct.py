"""This module provides functions for facilitating the creation of a
simplyct-based archive. Specifically, it is meant to parse OAI-PMH
dublin core encoded responses.

"""
import fileRSS2generator
import os
import time
import xml
from xml.dom.minidom import parse, parseString

def oaipmh2simplyctparser(inputfile):
    """Parser for OAI-PMH 1k batch records.

    keyword arguments:
    inputfile --batch file containing 1k OAI-PMH records

    """
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
            #simplyctwriter(xmldocument.toxml(), container, identifier)
            #print "End Processing ..."
        except xml.parsers.expat.ExpatError as details:
            print "Error Handling: ", details
            continue
        # call function for writing xmldocument
        #container = '../RSS2feeds2/' + container
        #identifier = identifier + '.metadata'
        #print "END: PREPROCESSING[PARSING]: ", time.time()
        simplyctwriter(xmldocument.toxml(), container, identifier)
        # start calling functions in fileRSS2generator module
        archivedir = '/home/lphiri/datasets/ndltd/RSS2feeds2'
        # update index file
        fileRSS2generator.rssindex(archivedir, record)
        # read index file to get a list of filies for rss feed generator function
        rss2indexlist = []
        with open('/home/lphiri/datasets/ndltd/scripts/index/RSS2-index.dat') as indexentries:
            for indexentry in indexentries:
                (key, values) = indexentry.split('|')
                rss2indexlist.append(key)
                print "DUMPING Index Entries...", key, " <-> ", values
        # generate rss feed
        print "Priting RSSindexlist...", rss2indexlist
        fileRSS2generator.writeRSS2file(rss2indexlist)
        # feed writeRSS2file function with output from rssindex function -- taking note that input is text file with pipe seperated entries
        #fileRSS2generator.writeRSS2file(fileRSS2generator.recentfiles(archivedir))

def simplyctwriter(xmldata, directory, filename):
    """Writes stripped dublin cored encoded record to disk

    keyword arguments:
    xmldata --chunked XML encoded record
    directory --container object where file is written to
    filename --filename used to write record to

    """
    #print "START: PREPROCESSING[WRITING]: ", time.time()
    # handle potentially malformed xml content
    xmldata = xmldata.encode('ascii', 'replace')
    # construct path to write output to
    if not os.path.exists(directory):
        os.makedirs(directory)
    xmlwriter = open(os.path.join(directory, filename), mode='w')
    xmlwriter.write(xmldata)
    xmlwriter.close()
    #print "END: PREPROCESSING[WRITING]: ", time.time()
