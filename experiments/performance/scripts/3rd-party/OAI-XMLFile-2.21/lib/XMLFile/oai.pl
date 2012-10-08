#!/usr/bin/perl -w -I.
use strict;

# +---------------------------------------------------------------------+
#    XMLFile OAI-PMH data provider
#    v2.21
#    August 2005
# +----------------------------------+----------------------------------+
# |  Hussein Suleman                 |  Department of Computer Science  |
# |   <hussein@cs.uct.ac.za>         |  University of Cape Town         |
# |   http://www.husseinsspace.com   |  Cape Town, South Africa         |
# +----------------------------------+----------------------------------+

# Installation :
#   copy all files into a directory from which you can execute scripts
#
# Testing :
#   use the repository explorer (http://purl.org/net/oai_explorer)
#   to test your interface


use FindBin;
use lib "$FindBin::Bin/../../lib";


use XMLFile::XMLFileDP;


sub main
{
   chdir "$FindBin::Bin";
   my $OAI = new XMLFile::XMLFileDP ('config.xml');
   $OAI->Run;
   $OAI->dispose;
}

main;
