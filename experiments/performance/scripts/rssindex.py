import os
import oaipmh2simplyct
import xml
from datetime import datetime
from xml.dom.minidom import parse, parseString

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
  # dateStamp for rss publication date
  rssdate = xmlrecord.getElementsByTagName('datestamp')[0].firstChild.data
  rssdate = datetime.strptime(rssdate.replace("T", " ").replace("Z", ""), '%Y-%m-%d %H:%M:%S') # format date string to convert to approapriate format
  # pre-processing input stream before writing
  try:
    xmldocument = parseString(xmlrecord.toxml().encode('utf-8'))
  except xml.parsers.expat.ExpartError as details:
    pass
  # write new object to repository the simplyct conventional way
  #simplyctwriter(xmldocument.toxml(), container, identifier)

  if os.path.exists("./index/RSS2-index.dat"):
    rssindexitems = {}
    with open("./index/RSS2-index.dat") as indexfile:
      for indexitem in indexfile:
        (key, value) = indexitem.split("|")
	rssindexitems[key] = datetime.strptime(value[:25], '%Y-%m-%d %H:%M:%S\n') # strip first 25 characters to avoice error --ValueError: unconverted data remains
        if len(rssindexitems) < 5:
          # add new object to dictionary if index items are less than limit
          rssindexitems[os.path.abspath(os.path.join(container, identifier))] = rssdate # get absolute path of file
        else:
          # deleted last item with minimum date in index
          del rssindexitems[[key for key, value in rssindexitems.items() if value==min(rssindexitems.values())][-1]]
	  rssindexitems[os.path.abspath(os.path.join(container, identifier))] = rssdate # slot in item
    # format and overwrite index file with new entries
    for key, value in sorted(rssindexitems.iteritems(), key=lambda(k, v): (v, k)):
      print "writing feed..."
      print "%s:%s" % (key, value)
      indexwriter = open("./index/RSS2-index.dat", mode="a+")
      indexwriter.write("%s|%s" % (key, value))
      indexwriter.write('\n') # new line for next record
      indexwriter.close()
