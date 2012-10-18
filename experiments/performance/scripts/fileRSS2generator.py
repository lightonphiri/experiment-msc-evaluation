# A module for ...
import datetime
import heapq
import os
import PyRSS2Gen
import time
import xml
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

# a function for writing objects to rssindex file
def rssindex(xmlrecord):
  # parse xml file
  #xmlrecord = parse(xmlrecorddoc)
  # identifier for file name
  identifier = xmlrecord.getElementsByTagName('identifier')[0].firstChild.data
  identifier = identifier.replace("/", "--") # replace '/' with two hyphens
  identifier = identifier.replace(":", "-") # replace ':' with single hyphen
  identifier = identifier + '.metadata'
  # setSpec for level-1 container name
  container = xmlrecord.getElementsByTagName('setSpec')[0].firstChild.data
  container = '../RSS2feeds2/' + container
  # dateStamp for rss publication date
  rssdate = xmlrecord.getElementsByTagName('datestamp')[0].firstChild.data
  rssdate = datetime.strptime(rssdate.replace("T", " ").replace("Z", ""), '%Y-%m-%d %H:%M:%S') # format date string to convert to approapriate format
  # pre-processing input stream before writing
  try:
    xmldocument = parseString(xmlrecord.toxml().encode('utf-8'))
  except xml.parsers.expat.ExpatError as details:
    pass
  # write new object to repository the simplyct conventional way
  #simplyctwriter(xmldocument.toxml(), container, identifier)
  rss2indexer = os.path.abspath('./index/RSS2-index.dat')
  print "Index file location: ", rss2indexer
  if os.path.exists(rss2indexer):
    rssindexitems = {}
    with open(rss2indexer) as indexfile:
      # check if file has content
      if os.path.getsize(rss2indexer) > 0:
        for indexitem in indexfile:
          (key, value) = indexitem.split("|")
	  rssindexitems[key] = datetime.strptime(value[:25], '%Y-%m-%d %H:%M:%S\n') # strip first 25 characters to avoice error --ValueError: unconverted data remains
          print "Checking index size...", len(rssindexitems)
	  print "Checking index contents...", rssindexitems
      else:
        rssindexitems[os.path.abspath(os.path.join(container, identifier))] = rssdate
    if len(rssindexitems) < 5:
      print "index before: ", rssindexitems
      # add new object to dictionary if index items are less than limit
      print "Index too small --Adding object to index...", os.path.abspath(os.path.join(container, identifier))
      rssindexitems[str(os.path.abspath(os.path.join(container, identifier)))] = rssdate # get absolute path of file
      print "index after: ", rssindexitems
    else:
      # deleted last item with minimum date in index
      del rssindexitems[[key for key, value in rssindexitems.items() if value==min(rssindexitems.values())][-1]]
      rssindexitems[os.path.abspath(os.path.join(container, identifier))] = rssdate # slot in item
    # format and overwrite index file with new entries
    print "last for statement..."
    print "index to write: ", rssindexitems
    indexwriter = open("./index/RSS2-index.dat", mode="w")
    for key, value in sorted(rssindexitems.iteritems(), key=lambda(k, v): (v, k)):
      print "writing feed..."
      print "%s:%s" % (key, value)
      #indexwriter = open("./index/RSS2-index.dat", mode="w")
      indexwriter.write("%s|%s" % (key, value))
      indexwriter.write('\n') # new line for next record
      #indexwriter.close()
    print "index written: ", rssindexitems
    indexwriter.close()

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
# takes heapq output as input
def __writeRSS2file(inputitems):
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
  rss.write_xml(open("new-simplyctrss2.xml", "w"))
  print "END: FEED GENERATOR[WRITING]: ", time.time()
  
# function to write list results from recentfiles function
def writeRSS2file(inputitems):
  print "START: FEED GENERATOR[WRITING]: ", time.time()
  feed_items = [] # define empty list
  for item in inputitems:
    print "appending... ", item
    feed_items.append(RSS2format(item)) # append items
  rss = PyRSS2Gen.RSS2(
    title = "A File-based RSS Feed Generator",
    link = "lphiri.cs.uct.ac.za/simplyct",
    description = "A File-based RSS Feed Generator",
    lastBuildDate = datetime.utcnow(),
    items = feed_items
  )
  print feed_items
  rss.write_xml(open("new-simplyctrss2.xml", "w"))
  print "END: FEED GENERATOR[WRITING]: ", time.time()
