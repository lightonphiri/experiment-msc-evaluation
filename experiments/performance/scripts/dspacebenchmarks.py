"""This module provides workload-related functions for performing
performance evaluation experiments.

"""

__name__ = "simplyctperformance"
__version__ = "1.0.0"
__author__ = "Lighton Phiri"
__email__ = "lighton.phiri@gmail.com"


import os
import sys

from lxml import etree

def dspace_structure(dataset, workload, listsetxml):
        """Function for creating DSpace structures..
        Crawls workload structure to generate XML file for DSpace collection ingestion.

        keyword arguments:
        dataset --workload dataset location
        workload --workload name

        Usage: python -c "import dspacebenchmarks; dspacebenchmarks.dspace_structure()"

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
                    collection = etre.Element("collection")
                    collection_identifier = "123456789/"+str(handlecounter)
                    collection.set("identifier", collection_identifier)
                    collection_name = etree.Element("name")
                    collection_name.text = set.find("setSpec").text
                    collection.append(collection_name)
                    collection_description = etree.Element("description")
                    collection_description.txt = set.find("setName").text
                    collection.append(collection_description)
                    community.append(collection)
                    handlecounter += 1
        elementtree = etree.ElementTree(root)
        workloadstructurefile = workload + "-structure.xml"
        elementtree.write(workloadstructurefile)
