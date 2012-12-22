"""This module provides workload-related functions for performing
performance evaluation experiments.

"""

__name__ = "simplyctperformance"
__version__ = "1.0.0"
__author__ = "Lighton Phiri"
__email__ = "lighton.phiri@gmail.com"

import os
import random
import requests
import shutil
import time
import urllib2
import xml
from urllib2 import *
from xml.dom.minidom import parse, parseString


def amfumuw1():
    """Entry point for module.
    Spawns different workload models --wN-- based on file limits.

    keyword arguments:
    none

    Usage: python -c "import simplyctperformance; simplyctperformance.amfumuw1()"

    """
    workloadstest = (('w1', 5), ('w2', 10), ('w3', 10), ('w4', 15), ('w5', 20), ('w6', 30), ('w7', 40), ('w8', 70), ('w9', 180), ('w10', 1440), ('w11', 1440), ('w12', 1800), ('w13', 3600), ('w14', 9000))
    for workload in workloadstest:
        workloadname = workload[0]
        workloadsleep = workload[1]
        print "START: ", workloadname
        coreurl = "http://localhost:8983/solr/" + workloadname + "/"
        print coreurl
        for manamba in range(1, 6):
            # purge any indicies available
            solrissuequery(coreurl, 'delete')
            solrissuequery(coreurl, 'commit')
            # issue solr import query
            solrissuequery(coreurl, 'import')
            time.sleep(workloadsleep)
            # loop until status is true
            while solrimportstatus(coreurl) is False:
                # print "Status: Busy... Waiting..." + str(workloadsleep) + "
                # seconds"
                time.sleep(20)
            solrstatusmesseges(coreurl)
            #solrissuequery(coreurl, 'delete')
            #solrissuequery(coreurl, 'commit')
        print "END: ", workloadname


def solrupdatesbatchmain(batchpath):
    #cores = ('w1', 'w2', 'w3', 'w4', 'w5', 'w6', 'w7', 'w8', 'w9', 'w10', 'w11', 'w12', 'w13', 'w14', 'w15')
    cores = ('w5',)
    for core in cores:
        coreurl = 'http://localhost:8983/solr/' + core + '/'
        batchlocation = batchpath
        for commits in ('true', 'false'):
            print "START: ", core
            solrupdatesbatch(coreurl, batchlocation, commits)
            print "END: ", core


def solrupdatesbatch(coreurl, batcheslocation, commit='true'):
    #workloads = (('b1', 'w1'), ('b2', 'w2'), ('b3', 'w3'), ('b4', 'w4'))
    workloads = (('b1', 'w1'), ('b2', 'w2'))
    for workload in workloads:
        batchname = workload[0]
        workloadname = workload[1]
        # add batch to index
        starttime = time.time()*1000
        for root, dirs, files in os.walk(os.path.join(batcheslocation, workloadname)):
            for filename in files:
                if filename.endswith('.metadata'):
                    # start counting from the time file is picked up
                    filestarttime = time.time()*1000
                    # add file to index
                    print "add", ",", batchname, ",", "commit : ", commit, ",", solritemquery(coreurl, 'add', os.path.abspath(os.path.join(root, filename)), commit, translator='x.xsl'), ",", "FileProcessing : ",(time.time()*1000)-filestarttime
                    # delete file from index
        print "add", ",", batchname, ",", "status : 0", ",", "Total : ", (time.time()*1000) - starttime
        # now delete what was added to clear index for next batch
        for root, dirs, files in os.walk(os.path.join(batcheslocation, workloadname)):
            for filename in files:
                if filename.endswith('.metadata'):
                    print "delete", ",", batchname, ",", solritemquery(coreurl, 'delete', os.path.abspath(os.path.join(root, filename)), commit, translator='x.xsl')


def spawnrandomworkload(dataset, destination, bin):
    """Spawns random sets of experiment workloads.

    keyword arguments:
    dataset --location of original dataset to spawn
    destination --base location where workloads will be created

    """
    workloads = (('w1', 100), ('w2', 200), ('w3', 400), ('w4', 800), ('w5', 1600), ('w6', 3200), ('w7', 6400), ('w8', 12800), ('w9', 25600), ('w10', 51200), ('w11', 102400), ('w12', 204800), ('w13', 409600), ('w14', 819200))
    swallowdataset = [str(os.path.abspath(os.path.join(root, filename))+":"+os.path.join(destination, bin, os.path.dirname(os.path.relpath(os.path.abspath(os.path.join(root, filename)), dataset)))).split(':',2) for root, dirs, files in os.walk(dataset) for filename in files if filename.endswith('.metadata')]
    for workload in workloads:
        if workload[0] == bin:
            payload = random.sample(swallowdataset, workload[1])
            for cargo in payload:
                if not os.path.exists(cargo[1]):
                    os.makedirs(cargo[1])
                shutil.copy2(cargo[0], cargo[1])


def spawnworkload(dataset, destination):
    """Spawns and creates experiment workloads.
    Creates directories comprising of desired load --number of files.

    keyword arguments:
    dataset --location of original dataset to spawn
    destination --base location where workloads will be created

    """
    workloads = (('w1', 100), ('w2', 200), ('w3', 400), ('w4', 800), ('w5', 1600), ('w6', 3200), ('w7', 6400), ('w8', 12800), ('w9', 25600), ('w10', 51200), ('w11', 102400), ('w12', 204800), ('w13', 409600), ('w14', 819200))
    for workload in workloads:
        workloadname = workload[0]
        workloadlimit = workload[1]
        workloadvalue = 1
        for root, dirs, files in os.walk(dataset):
            for filename in files:
                if filename.endswith('.metadata'):
                    #directory = os.path.dirname(os.path.relpath(os.path.abspath(os.path.join(root, file)), dataset))
                    #directory = os.path.dirname(os.path.relpath(os.path.abspath(os.path.join(root, filename))))
                    directory = os.path.dirname(os.path.relpath(os.path.abspath(os.path.join(root, filename)), dataset))
                    #directory = directory[directory.index('/')+1:] # remove contextual directory
                    #directory = directory[directory.index('/') + 1:]
                    #directory = os.path.join(destination, workloadname, directory)
                    directory = os.path.join(destination, workloadname, directory)
                    #workloadfile = os.path.relpath(os.path.abspath(os.path.join(root, file)), dataset)
                    workloadfile = os.path.abspath(os.path.join(root, filename))
                    print workloadfile
                    print directory
                    if not os.path.exists(directory):
                        os.makedirs(directory)
                    shutil.copy2(workloadfile, directory)
                    workloadvalue += 1
                    if workloadvalue > workloadlimit:
                        break
            if workloadvalue > workloadlimit:
                break
        if workloadvalue > workloadlimit:
            continue


def spawnstructworkload(dataset, destination, workloadname):
    """Spawns and creates experiment workloads.
    Creates 3-level directory structure comprising of desired
    load --number of files.

    keyword arguments:
    dataset --location of original dataset (resulting from spawnworkload fxn) to spawn
    destination --base location where workloads will be created

    Usage: python -c "import simplyctperformance; simplyctperformance.spawnstructworkload(d1,d2)"

    """
    for root, dirs, files in os.walk(dataset):
        for filename in files:
            if filename.endswith('.metadata'):
                directory = os.path.dirname(os.path.relpath(os.path.abspath(os.path.join(root, filename)), dataset))
                print root
                print os.path.join(root, filename)
                print os.path.abspath(os.path.join(root, filename))
                print os.path.relpath(os.path.abspath(os.path.join(root, filename)))
                print os.path.dirname(os.path.relpath(os.path.abspath(os.path.join(root, filename))))
                print "DIR1: ", directory
                #directory = directory[directory.index('/') + 1:] # TODO: investigate why this caused errors
                print "DIR2: ", directory
                directory = os.path.join(destination, workloadname, directory)
                print "DIR3: ", directory
                workloadfile = os.path.abspath(os.path.join(root, filename))
                print "Parsing: ", filename
                simplyctdom = parse(workloadfile) # parse input file
                dccreator = ""
                dcdate = ""
                for records in simplyctdom.getElementsByTagName('metadata'):
                    try:
                        # TODO: handle different date formats here (e.g.
                        # YYYY-MM-DD; YYYY; YYYY-MM)
                        # For now, cheap trick is to strip off first 4 digits
                        #dcdate = str(records.getElementsByTagName('dc:date')[0].firstChild.data).strip()[:4]
                        for resourcedate in records.getElementsByTagName('dc:date'):
                            try:
                                dcdate = resourcedate.firstChild.data.strip()[:4]
                                break
                            except Exception as detail:
                                dcdate = "unknown"
                                continue
                    # TODO: proper error handling here Phiri
                    except Exception as details:
                        dcdate = "unknown"
                    try:
                        #dccreator = str(records.getElementsByTagName('dc:creator')[0].firstChild.data).strip()[:1].lower()
                        for creator in records.getElementsByTagName('dc:creator'):
                            try:
                                dccreator = str(creator.firstChild.data).strip()[:1].lower()
                                break
                            except Exception as detail:
                                dccreator = "unknown"
                                continue
                    # TODO: proper error handling here Phiri
                    except Exception as details:
                        dccreator = "unknown"
                # normalise element text
                # check date and string formats
                if ((len(dcdate) == 4) & (dcdate != "unknown")):
                    # check if first four digits is number
                    try:
                        dcdate = str(int(dcdate))
                    except Exception as details:
                        dcdate = 'unknown'
                elif (dcdate == ""): # if no node exists
                    dcdate = "unknown"
                if (not(dccreator.isalpha())):
                    dccreator = 'unknown'
                print os.path.join(dcdate, dccreator)
                #
                workloadfile = os.path.abspath(os.path.join(root, filename))
                workloadpath = os.path.join(directory, dcdate, dccreator)
                print workloadpath
                print workloadfile
                if not os.path.exists(workloadpath):
                    os.makedirs(workloadpath)
                shutil.copy2(workloadfile, workloadpath)


def solrissuequery(coreurl, query):
    """Sends Solr HTTP request to Solr server.

    keyword arguments:
    coreurl --Solr core base URL, e.g. http://host:port/core/
    query --commit, delete or import

    """
    headers = {"Content-type": "text/xml", "charset": "utf-8"}
    if query == 'import':
        querycontext = "dataimport?command=full-import"
        solrquery = urlparse.urljoin(coreurl, querycontext)
        urlopen(solrquery)
    elif query == 'delete':
        querycontext = "update"
        solrquery = urlparse.urljoin(coreurl, querycontext)
        solrrequest = urllib2.Request(solrquery, '<delete><query>*:*</query></delete>', headers)
        solrresponse = urllib2.urlopen(solrrequest)
        #solrresult = solrresponse.read()
        solrresponse.read()
        #print solrresult
    elif query == 'commit':
        querycontext = "update"
        solrquery = urlparse.urljoin(coreurl, querycontext)
        solrrequest = urllib2.Request(solrquery, '<commit/>', headers)
        solrresponse = urllib2.urlopen(solrrequest)
        #solrresult = solrresponse.read()
        solrresponse.read()
        #print solrresult
    #solrquery = urlparse.urljoin(coreurl, querycontext)
    #print solrquery
    #solrconnection = urlopen(solrquery)

def solritemquery(coreurl, query, solrfile, commit='true', translator='x.xsl'):
    """Sends Solr HTTP item requests to Solr server.

    keyword arguments:
    coreurl --Solr core base URL, e.g. http://host:port/core/
    query --commit, delete or import
    solrfile --Solr file to index
    translator --optional xslt stylesheet; not required for delete et al.

    """
    headers = {"Content-type": "text/xml", "charset": "utf-8"}
    if query == 'add':
        querycontext = "update?commit=" + commit + "&tr=" + translator
        solrquery = urlparse.urljoin(coreurl, querycontext)
        solrdata = open(solrfile, 'rb').read() # the payload
        solrresponse = requests.post(solrquery, data=solrdata, headers=headers)
        #print "Indexing Response for: ", solrfile, " : ", solrresponse.status_code
        #print solrresponse.status_code
        #print parseString(solrresponse.text).toprettyxml()
        solrresponsehead(solrresponse.text)
    elif query == 'delete':
        querycontext = "update"
        solrquery = urlparse.urljoin(coreurl, querycontext)
        solrrequest = urllib2.Request(solrquery, '<delete><id>' + ndltdidentifier(solrfile) + '</id></delete>', headers)
        solrresponse = urllib2.urlopen(solrrequest)
        #solrresult = solrresponse.read()
        #print solrresponse.read()
        solrresponsehead(solrresponse.read())
        #print solrresult
        # commit the transaction
        delrequest = urllib2.Request(solrquery, '<commit/>', headers)
        delresponse = urllib2.urlopen(delrequest)
        delresponse.read()
    elif query == 'commit':
        querycontext = "update"
        solrquery = urlparse.urljoin(coreurl, querycontext)
        solrrequest = urllib2.Request(solrquery, '<commit/>', headers)
        solrresponse = urllib2.urlopen(solrrequest)
        #solrresult = solrresponse.read()
        solrresponse.read()
        #print solrresult
    #solrquery = urlparse.urljoin(coreurl, querycontext)
    #print solrquery
    #solrconnection = urlopen(solrquery)


def solrstatusmesseges(coreurl):
    """Prints out name value pairs of Solr import results.

    keyword arguments:
    coreurl --Solr core base URL, e.g. http://host:port/core/

    """
    querycontext = "dataimport"
    solrquery = urlopen(urlparse.urljoin(coreurl, querycontext))
    solrresponse = solrquery.read()
    solrxml = parseString(solrresponse)
    for solrnode in solrxml.getElementsByTagName('lst'):
        if str(solrnode.getAttribute('name')) == 'statusMessages':
            for solrstatus in solrnode.getElementsByTagName('str'):
                if str(solrstatus.getAttribute('name')) != "":
                    print solrstatus.getAttributeNode('name').nodeValue, ":", solrstatus.firstChild.data, ",",
            print "\n"

def solrresponsehead(solrresponse):
    """Prints out proper format for response header.

    keyword arguments:
    result --Solr XML response formatted string text

    """
    solrxml = parseString(solrresponse)
    for solrnode in solrxml.getElementsByTagName('int'):
        if (solrnode.getAttribute('name') == 'status') | (solrnode.getAttribute('name') == 'QTime'):
            print solrnode.getAttribute('name'), ":", solrnode.firstChild.data,",",
            #print "\n"

def ndltdidentifier(ndltdfile):
    """Extracts identifier from record.

    keywords arguments:
    ndltdfile --XML encoded file containing records
    """
    ndltddom = parse(ndltdfile)
    identifer = ""
    for record in ndltddom.getElementsByTagName('header')[0].getElementsByTagName('identifier'):
        identifier = str(record.firstChild.data)
    return identifier

def solrimportstatus(coreurl):
    """Returns boolean indicating if import is complete.
    Check if import status is busy or idle.

    keyword arguments:
    coreurl --Solr core base URL, e.g. http://host:port/core/

    """
    querycontext = "dataimport"
    solrimportquery = urlopen(urlparse.urljoin(coreurl, querycontext))
    solrresponse = solrimportquery.read()
    solrxml = parseString(solrresponse)
    for solrnode in solrxml.getElementsByTagName('str'):
        if str(solrnode.getAttribute('name')) == 'status':
            if solrnode.firstChild.data == 'idle':
                return True
            else:
                return False
