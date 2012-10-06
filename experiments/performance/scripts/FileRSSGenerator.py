# A module for 
import datetime
import os
import heapq
import PyRSS2Gen

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
  return heapq.nlargest(5, molecollector(archive))
  


# function to read xml document and pull out relevant information for feeds
# title -> dc:title
# description -> dc:description
# link -> file path
# pubDate -> creation date from recentfiles() function
# guid -> unique archive path



  
# function to generate xml file feed
