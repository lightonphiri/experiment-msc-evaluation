"""This module provides workload-related functions for performing
performance evaluation experiments.

"""

__name__ = "dspacebenchmarks"
__version__ = "1.0.0"
__author__ = "Lighton Phiri"
__email__ = "lighton.phiri@gmail.com"


import psycopg2
import os
import sys

from lxml import etree

def dspacestructure(dataset, workload, listsetxml):
    """Function for creating DSpace structures..
    Crawls workload structure to generate XML file for DSpace collection ingestion.

    keyword arguments:
    dataset --workload dataset location
    workload --workload name

    Usage: python -c "import dspacebenchmarks; dspacebenchmarks.dspacestructure()"

    """
    root = etree.Element("import_structure")
    community = etree.Element("community")
    community.set("identifier", "123456789/1")
    community_name = etree.Element("name")
    community_name.text = workload
    community.append(community_name)
    community_description = etree.Element("description")
    community_description.text = workload
    community.append(community_description)
    root.append(community)
    # incremental counter for DSpace unique identifiers
    handlecounter = 2
    workloadsets = sorted(os.listdir(dataset))
    # parse ListSet output XML file
    # TODO: only works without namespaces for now; to look into
    setspecs = etree.parse(listsetxml)
    for workloadset in workloadsets:
        for set in setspecs.findall(".//set"):
            if (str(set.find("setSpec").text).encode('ascii', 'ignore') == workloadset):
                collection = etree.Element("collection")
                collection_identifier = "123456789/"+str(handlecounter)
                collection.set("identifier", collection_identifier)
                collection_name = etree.Element("name")
                collection_name.text = set.find("setSpec").text
                collection.append(collection_name)
                collection_description = etree.Element("description")
                collection_description.text = set.find("setName").text
                collection.append(collection_description)
                community.append(collection)
                handlecounter += 1
    elementtree = etree.ElementTree(root)
    workloadstructurefile = workload + "-structure.xml"
    elementtree.write(workloadstructurefile)

def dspaceBMEformat(xmlfile, database):
    """Function for converting input XML to dspace BME format.
    Parses input XML file and output equivalent DSpace Batch Metadata Editing format.

    keyword arguments:
    xmlfile --input XML file
    csvfile --output file to write to

    Usage: python -c "import dspacebenchmarks; dspacebenchmarks.dspaceBMEformat()"

    """
    xmlfileobject = etree.parse(xmlfile)
    csvpayload = []
    dcelementdelimiter = "|||"
    dspacefielddelimiter = "$$$"
    # item id
    id = "+"
    csvpayload.append(id)
    # retriev collection id from XML input file
    collectionname = dspacedcelementlist(xmlfileobject.xpath("//*[local-name() = 'setSpec']"))[0]
    collectionid = dspacedbcollectionhandle(collectionname,database=database)
    csvpayload.append(collectionid)
    # dc.identifier
    try:
        identifiers = dspacedcelementcsv(dspacedcelementlist(xmlfileobject.xpath("//*[local-name() = 'identifier']")), dcelementdelimiter)
    except Exception as detail:
        identifiers = ""
    csvpayload.append(identifiers)
    # dc.title
    try:
        titles = dspacedcelementcsv(dspacedcelementlist(xmlfileobject.xpath("//*[local-name() = 'title']")), dcelementdelimiter)
    except Exception as detail:
        titles = ""
    csvpayload.append(titles)
    # dc.publisher
    try:
        publishers = dspacedcelementcsv(dspacedcelementlist(xmlfileobject.xpath("//*[local-name() = 'publisher']")), dcelementdelimiter)
    except Exception as detail:
        publishers = ""
    csvpayload.append(publishers)
    # dc.creator
    try:
        creators = dspacedcelementcsv(dspacedcelementlist(xmlfileobject.xpath("//*[local-name() = 'creator']")), dcelementdelimiter)
    except Exception as detail:
        creators = ""
    csvpayload.append(creators)
    # dc.subject
    try:
        subjects = dspacedcelementcsv(dspacedcelementlist(xmlfileobject.xpath("//*[local-name() = 'subjects']")), dcelementdelimiter)
    except Exception as detail:
        subjects = ""
    csvpayload.append(subjects)
    # dc.description
    try:
        descriptions = dspacedcelementcsv(dspacedcelementlist(xmlfileobject.xpath("//*[local-name() = 'description']")), dcelementdelimiter)
    except Exception as detail:
        descriptions = ""
    csvpayload.append(descriptions)
    # dc.contributor
    try:
        contributors = dspacedcelementcsv(dspacedcelementlist(xmlfileobject.xpath("//*[local-name() = 'contributor']")), dcelementdelimiter)
    except Exception as detail:
        contributors = ""
    csvpayload.append(contributors)
    # dc.issued
    try:
        dates = dspacedcelementcsv(dspacedcelementlist(xmlfileobject.xpath("//*[local-name() = 'date']")), dcelementdelimiter)
    except Exception as detail:
        dates = ""
    csvpayload.append(dates)
    # dc.type
    try:
        types = dspacedcelementcsv(dspacedcelementlist(xmlfileobject.xpath("//*[local-name() = 'type']")), dcelementdelimiter)
    except Exception as detail:
        types = ""
    csvpayload.append(types)
    # dc.format
    try:
        formats = dspacedcelementcsv(dspacedcelementlist(xmlfileobject.xpath("//*[local-name() = 'format']")), dcelementdelimiter)
    except Exception as detail:
        formats = ""
    csvpayload.append(formats)
    # dc.language
    try:
        languages = dspacedcelementcsv(dspacedcelementlist(xmlfileobject.xpath("//*[local-name() = 'language']")), dcelementdelimiter)
    except Exception as detail:
        languages = ""
    csvpayload.append(languages)
    # dc.relation
    try:
        relations = dspacedcelementcsv(dspacedcelementlist(xmlfileobject.xpath("//*[local-name() = 'relation']")), dcelementdelimiter)
    except Exception as detail:
        relations = ""
    csvpayload.append(relations)
    # dc.coverage
    try:
        coverages = dspacedcelementcsv(dspacedcelementlist(xmlfileobject.xpath("//*[local-name() = 'coverage']")), dcelementdelimiter)
    except Exception as detail:
        coverages = ""
    csvpayload.append(coverages)
    # dc.rights
    try:
        rights = dspacedcelementcsv(dspacedcelementlist(xmlfileobject.xpath("//*[local-name() = 'rights']")), dcelementdelimiter)
    except Exception as detail:
        rights = ""
    csvpayload.append(rights)
    return dspacedcelementcsv(csvpayload, dspacefielddelimiter) + "\n"


def dspacedcelementlist(dcelementslist):
    """Function for returning cleaned element list set.
    It basically takes a DC element list and weeds out the text nodes

    keyword arguments:
    dcelementslist --input list
    """
    refinedlist = []
    for element in dcelementslist:
        # append element values to resultset
        refinedlist.append(element.text.replace('\n', '').replace('"',''))
    return refinedlist


def dspacedcelementcsv(dcelementlist, delimiter):
    """Function for concatenating DC element list
    It basically concatenates element list with specified character(s)
    """
    return delimiter.join(dcelementlist)


def dspaceitemcollection(xmlfile):
    """Function for concatenating DC element list
    It basically concatenates element list with specified character(s)
    """
    return True

def dspacedbcollectionhandle(collectionname, host='blabusch.cs.uct.ac.za', port='5432', database='dspace', user='dspace', password='dspace'):
    """Function to query DSpace database to get collection ID.
    Connection to the database , issues relevant query and pull out desired information

    keyword arguments:
    collectionname --the name of the collection
    host --database host
    port --database port
    database --database name
    user --database username
    password --database password
    """
    con = None
    collectionid = ""
    try:
        con = psycopg2.connect(host=host, port=port, database=database, user=user, password=password)
        cur = con.cursor()
        selectquery = "SELECT h.handle FROM ((SELECT resource_id, handle FROM handle WHERE resource_type_id = 3) as h JOIN (SELECT collection_id, name FROM collection) as c ON h.resource_id = c.collection_id) WHERE name ='" + collectionname + "';"
        selectquery2 = "SELECT h.handle FROM ((SELECT resource_id, handle FROM handle WHERE resource_type_id = 3) as h JOIN (SELECT collection_id, name FROM collection) as c ON h.resource_id = c.collection_id) LIMIT 1;"
        cur.execute(selectquery)
        rows = cur.fetchall()
        print collectionname,":::",rows
        if (len(rows) == 0):
            cur.execute(selectquery2)
            rows = cur.fetchall()
        collectionid = rows[0][0]
        #for row in rows:
        #    print row
    except psycopg2.DatabaseError, e:
        print 'Error %s' % e
        sys.exit(1)
    finally:
        if con:
            con.close()
    return collectionid


def dspacecsvfile(dataset, workload, recordsize, database):
    """Function to write chunks of files for ingestion into DSpace.
    """
    header = "id$$$collection$$$dc.identifier$$$dc.title$$$dc.publisher$$$dc.creator$$$dc.subject$$$dc.description$$$dc.contributor$$$dc.date$$$dc.type$$$dc.format$$$dc.language$$$dc.relation$$$dc.coverage.temporal$$$dc.rights" + "\n"
    recordcounter = 1
    filecounter = 1
    dspaceingestfile = workload + "-" + str(recordsize) + "-" + str(filecounter) + ".csv"
    #dspaceingestfile.write(header)
    with open(dspaceingestfile, 'a') as initialfileheader:
        initialfileheader.write(header)
    for root, dirs, files in os.walk(dataset):
        for filename in files:
            if filename.endswith('.metadata'):
                if recordcounter > recordsize:
                    # if recordsize limit is exceeded, spawn new file
                    filecounter += 1
                    # reset recordcounter
                    recordcounter = 1
                    dspaceingestfile = workload + "-" + str(recordsize) + "-" + str(filecounter) + ".csv"
                    #dspaceingestfile.write(header)
                    with open(dspaceingestfile, 'a') as outputfileheader:
                        outputfileheader.write(header)
                print "Processing: ",os.path.abspath(os.path.join(root, filename))
                with open(dspaceingestfile, 'a') as outputfile:
                    outputfile.write(dspaceBMEformat(os.path.abspath(os.path.join(root, filename)), database).encode('ascii', 'ignore'))
                recordcounter += 1
