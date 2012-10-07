# A module for ...
import datetime
import heapq
import os
import PyRSS2Gen
import time
from datetime import datetime
from xml.dom.minidom import parse, parseString

# function to generate files in archive with corresponding ctimes
def molecollector(archive):
  for root, dirs, files in os.walk(archive):
    for filename in files:
      if filename.endswith('.metadata'):
	pathname = os.path.abspath(os.path.join(root, filename))
	try:
	  yield os.stat(pathname).st_ctime, pathname
	except os.error as details:
	  print "Handling error: ", details

# function for getting a list of top 10 most recently created files based on their ctimes
# please see http://docs.python.org/library/heapq.html
def recentfiles(archive):
  print "START: FEED GENERATOR[HEAPQ]: ", time.time()
  return heapq.nlargest(5, molecollector(archive))
  print "END: FEED GENERATOR[HEAPQ]: ", time.time()

# function to read xml document and pull out relevant information for feeds
# title -> dc:title
# description -> dc:description
# link -> file path
# pubDate -> creation date from recentfiles() function
# guid -> unique archive path
def RSS2format(inputfile):
  print "START: FEED GENERATOR[ITEM OBJECT CREATOR]: ", time.time()
  xmldocument = parse(inputfile)
  feed_title = ""
  try:
    feed_title = xmldocument.getElementsByTagName('dc:title')[0].firstChild.data
  except IndexError as details:
    print "Handling IndexError: ", details
    feed_title = "Handling IndexError..."
  except AttributeError as details:
    print "Handling AttributeError: ", details
    feed_title = "Handling AttributeError..."
  # only get first 100 characters.. RSS
  feed_description = ""
  try:
    feed_description = xmldocument.getElementsByTagName('dc:description')[0].firstChild.data[:100]
  except IndexError as details:
    print "Handling IndexError: ", details
    feed_description = "Handling IndexError"
  feed_link = xmldocument.getElementsByTagName('identifier')[0].firstChild.data # get header identifier for link value
  feed_pubDate = xmldocument.getElementsByTagName('datestamp')[0].firstChild.data # get header datestamp for pubDate value
  feed_guid = xmldocument.getElementsByTagName('identifier')[0].firstChild.data # get header identifier for guid value
  
  return PyRSS2Gen.RSSItem(
    title = feed_title,
    link = feed_link,
    description = feed_description,
    guid = feed_guid,
    pubDate = datetime.strptime(feed_pubDate.replace("T", " ").replace("Z", ""), '%Y-%m-%d %H:%M:%S')
  )
  print "END: FEED GENERATOR[ITEM OBJECT CREATOR]: ", time.time()

# function to write list results from recentfiles function
def writeRSS2file(inputitems):
  print "START: FEED GENERATOR[WRITING]: ", time.time()
  feed_items = [] # define empty list
  for item in inputitems:
    print "appending... ", item[1]
    feed_items.append(RSS2format(item[1])) # append items
  rss = PyRSS2Gen.RSS2(
    title = "A File-based RSS Feed Generator",
    link = "lphiri.cs.uct.ac.za/simplyct",
    description = "A File-based RSS Feed Generator",
    lastBuildDate = datetime.utcnow(),
    items = feed_items
  )
  print feed_items
  rss.write_xml(open("simplyctrss2.xml", "w"))
  print "END: FEED GENERATOR[WRITING]: ", time.time()