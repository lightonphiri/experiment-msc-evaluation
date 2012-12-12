"""This module provides workload-related functions for performing
performance evaluation experiments.

"""

__name__ = "simplyctperformance"
__version__ = "1.0.0"
__author__ = "Lighton Phiri"
__email__ = "lighton.phiri@gmail.com"

import os
import shutil
import time
import urllib2
from urllib2 import *
from xml.dom.minidom import parseString


def amfumu():
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


def spawnworkload(dataset, destination):
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
                    directory = os.path.dirname(os.path.relpath(os.path.abspath(os.path.join(root, filename))))
                    #directory = directory[directory.index('/')+1:] # remove contextual directory
                    directory = directory[directory.index('/') + 1:]
                    #directory = os.path.join(destination, workloadname, directory)
                    directory = os.path.join(destination, workloadname, directory)
                    #workloadfile = os.path.relpath(os.path.abspath(os.path.join(root, file)), dataset)
                    workloadfile = os.path.abspath(os.path.join(root, filename))
                    if not os.path.exists(directory):
                        os.makedirs(directory)
                    shutil.copy2(workloadfile, destination)
                    workloadvalue += 1
                    if workloadvalue > workloadlimit:
                        break
            if workloadvalue > workloadlimit:
                break
        if workloadvalue > workloadlimit:
            continue


def solrissuequery(coreurl, query):
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


# function to print out status messages
#
def solrstatusmesseges(coreurl):
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


# function to check if import is busy or idle
#
def solrimportstatus(coreurl):
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
