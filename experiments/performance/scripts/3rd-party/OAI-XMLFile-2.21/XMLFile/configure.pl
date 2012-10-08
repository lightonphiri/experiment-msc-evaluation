#!/usr/bin/perl -I. -w
use strict;

# +---------------------------------------------------------------------+
#    configuration script for OAI - XMLFile
#    v2.21
#    August 2005
# +----------------------------------+----------------------------------+
# |  Hussein Suleman                 |  Department of Computer Science  |
# |   <hussein@cs.uct.ac.za>         |  University of Cape Town         |
# |   http://www.husseinsspace.com   |  Cape Town, South Africa         |
# +----------------------------------+----------------------------------+

# configure the OAI data provider layer


use FindBin;
use lib "$FindBin::Bin/../lib";

use Pure::EZXML;
use Pure::X2D;


# get a single configuration option from the parsed XML file
sub getOption
{
   my ($doc, $option, $embed) = @_;
   
   if (defined $embed)
   {
      my @embedparts = split ('/', $embed);
      for ( my $i=0; $i<=$#embedparts; $i++ )
      {
         my $element = $doc->getElementsByTagName ($embedparts[$i], 0);
         if ($element->getLength > 0)
         {
            $doc = $element->item(0);
         }
         else
         {
            return '';
         }
      }
   }
   
   my $element = $doc->getElementsByTagName ($option, 0);
   if ($element->getLength > 0)
   {
      my $instance = $element->item(0);
      return $instance->getChildNodes->toString;
   }
   else
   {
      return '';
   }
}


# read in configuration from config.xml and set best-guess defaults for 
# missing values
sub ReadConfig
{
   my ($configname) = @_;
   
   my $configfile = "$configname/config.xml";
   my $config = new Pure::X2D ($configfile);
   
   # get user information from system programs
   my $hostname = `hostname`; 
   my $username = `whoami`;
   if (defined $hostname)
   {
      $hostname =~ s/[\r\n\t\s]//go;
   }
   if (defined $username)
   {
      $username =~ s/[\n\r\t\s]//go;
   }
   my $creator = `finger $username | head -1 | cut -f 4 | cut -f 2- -d ':' | cut -d ' ' -f 2-`;
   if (defined $creator)
   {
      $creator =~ s/[\n\r]//go;
   }

   if ((! defined $config->{'repositoryName'}) || ($config->{'repositoryName'}->[0] eq ''))
   {
      $config->{repositoryName} = [ "$configname OAI Archive" ];
   }

   if ((! defined $config->{'adminEmail'}) || ($config->{'adminEmail'}->[0] eq ''))
   {
      $config->{'adminEmail'} = [ '' ];

      # guess admin id from hostname and user logged in
      if ((defined $hostname) && ($hostname ne '') && 
          (defined $username) && ($username ne ''))
      {
         $hostname =~ s/[\r\n\t\s]//go;
         $username =~ s/[\n\r\t\s]//go;
         
         $config->{'adminEmail'} = [ $username.'@'.$hostname ];
      }
   }

   if ((! defined $config->{'archiveId'}) || ($config->{'archiveId'}->[0] eq ''))
   { $config->{'archiveId'} = [ $configname ]; }

   if ((! defined $config->{'recordlimit'}) || ($config->{'recordlimit'}->[0] eq ''))
   { $config->{'recordlimit'} = [ 500 ]; }

   if ((! defined $config->{'datadir'}) || ($config->{'datadir'}->[0] eq ''))
   {
      $config->{'datadir'} = [ '' ];
      if ((defined $username) && ($username ne '')) 
      {
         $config->{'datadir'} = [ "data" ]; 
      }
   }

   if ((! defined $config->{'longids'}) || ($config->{'longids'}->[0] eq ''))
   { $config->{'longids'} = [ 'no' ]; }

   if ((! defined $config->{'filematch'}) || ($config->{'filematch'}->[0] eq ''))
   { $config->{'filematch'} = [ '[^\.]+\.[xX][mM][lL]$' ]; }

   if ((! defined $config->{'multiset'}) || ($config->{'multiset'}->[0] eq ''))
   { $config->{'multiset'} = [ 'no' ]; }
   if ((! defined $config->{'originalids'}) || ($config->{'originalids'}->[0] eq ''))
   { $config->{'originalids'} = [ 'no' ]; }
   if ((! defined $config->{'stripextensions'}) || ($config->{'stripextensions'}->[0] eq ''))
   { 
     if ($config->{'originalids'}->[0] eq 'yes')
     { $config->{'stripextensions'} = [ 'no' ]; }
     else
     { $config->{'stripextensions'} = [ 'yes' ]; }
   }
   if ((! defined $config->{'listsize'}) || ($config->{'listsize'}->[0] eq ''))
   { $config->{'listsize'} = [ 'no' ]; }

   $config->{'mdorder'} = [ qw ( repositoryName adminEmail archiveId recordlimit datadir longids filematch multiset originalids stripextensions listsize metadata ) ];

   if (! defined $config->{'metadata'})
   { $config->{'metadata'} = [ { } ]; }
   
   foreach my $metadata (@{$config->{'metadata'}})
   {
      if ((! defined $metadata->{'prefix'}) || ($metadata->{'prefix'} eq ''))
      { $metadata->{'prefix'} = [ 'oai_dc' ]; }
      if ((! defined $metadata->{'namespace'}) || ($metadata->{'namespace'} eq ''))
      { $metadata->{'namespace'} = [ 'http://www.openarchives.org/OAI/2.0/oai_dc/' ]; }
      if ((! defined $metadata->{'schema'}) || ($metadata->{'schema'} eq ''))
      { $metadata->{'schema'} = [ 'http://www.openarchives.org/OAI/2.0/oai_dc.xsd' ]; }
      if ((! defined $metadata->{'transform'}) || ($metadata->{'transform'} eq ''))
      { $metadata->{'transform'} = [ '' ]; }
      
      $metadata->{'mdorder'} = [ qw ( prefix namespace schema transform ) ];
   }

   $config;
}


# write configuration data and template files
sub WriteConfig 
{
   my ($config, $configname) = @_;
   
   mkdir ($configname, 0777);
   
   open (CONFIG, ">$configname/config.xml");
   print CONFIG "<?xml version=\"1.0\" ?>\n\n";
   print CONFIG "<xmlfile xmlns=\"http://simba.cs.uct.ac.za/projects/xmlfile\"\n".
                "    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n".
                "    xsi:schemaLocation=\"http://simba.cs.uct.ac.za/projects/xmlfile\n".
                "                         http://simba.cs.uct.ac.za/projects/xmlfile/xmlfile.xsd\"\n".
                ">\n\n";
   print CONFIG $config->toXML;
   print CONFIG "</xmlfile>\n";
   close (CONFIG);
   
   # copy the web application file
   open (my $s, "$FindBin::Bin/../lib/XMLFile/oai.pl");
   open (my $d, ">$configname/oai.pl");
   while (<$s>) { print $d $_; }
   close ($d);
   close ($s);
   chmod (0755, "$configname/oai.pl");
   
   mkdir ("$configname/data", 0777);
}


my $fastforward = 0;

# input a line of data, with prompt and default value
sub InputLine
{
   my ($variable, $prompt) = @_;
   
   if (defined $prompt)
   {
      print "$prompt [$$variable] : ";
   }
   if ($fastforward == 1)
   {
      print "$$variable\n";
      select(undef, undef, undef, 0.25);
   }
   else
   {
      my $line = <STDIN>;
      chomp $line;
      if ($line eq '&continue')
      {
         $fastforward = 1;
         print "$$variable\n";
      }
      elsif ($line eq '&delete')
      {
         $$variable = '';
         InputLine ($variable, $prompt);
      }
      elsif ($line ne '')
      {
         $$variable = $line;
      }
   }
}


# wait for user to press ENTER
sub InputEnter
{
   my $temp = '';
   InputLine (\$temp);
}


# check validity of input and print error if necessary
sub InvalidInput
{
   my ($check, $errormsg) = @_;
   
   if ($check)
   {
      print "$errormsg\n";
      $fastforward = 0;
      return 1;
   }
   0;
}


# configuration for a single metadata format
sub metadata_config
{
   my ($metadata) = @_;

   # prefix
   print "\n[METADATA PREFIX]\n";
   print "You need a unique name by which to refer to the metadata format\n";
   print "Examples: oai_dc, oai_rfc1807\n\n";
   do {
      InputLine (\$metadata->{'prefix'}->[0], "Metadata prefix");
   } while (InvalidInput (($metadata->{'prefix'}->[0] eq ''),
                          "This field cannot be left blank. Please enter a value."));


   # namespace
   print "\n[METADATA NAMESPACE]\n";
   print "What is the XML namespace for this metadata format ?\n";
   print "Example: for oai_dc it is http://www.openarchives.org/OAI/2.0/oai_dc/\n\n";
   do {
      InputLine (\$metadata->{'namespace'}->[0], "Metadata namespace");
   } while (InvalidInput (($metadata->{'namespace'}->[0] eq ''),
                          "This field cannot be left blank. Please enter a value."));


   # schema
   print "\n[METADATA SCHEMA]\n";
   print "Where is the XML Schema for this metadata format ?\n";
   print "Example: for oai_dc it is http://www.openarchives.org/OAI/2.0/oai_dc.xsd\n\n";
   do {
      InputLine (\$metadata->{'schema'}->[0], "Metadata schema");
   } while (InvalidInput (($metadata->{'schema'}->[0] eq ''),
                          "This field cannot be left blank. Please enter a value."));


   # transform
   print "\n[METADATA TRANSFORMATION]\n";
   print "Enter the command line that takes any source file as input and\n".
         "produces a version in $metadata->{'prefix'}->[0]. Leave empty\n".
         "if no transformation is required\n";
   print "Example: /usr/local/bin/xsltproc vra2dc.xsl - |\n\n";
   InputLine (\$metadata->{'transform'}->[0], "Metadata tranform");
}


# main program body !
sub main 
{
   $| = 1;
   my $ok;
   
   print "+----------------------------------------------+\n".
         "| OAI XMLFile v2.21 Configurator               |\n".
         "+----------------------------------------------+\n".
         "| August 2005                                  |\n".
         "| Hussein Suleman <hussein\@cs.uct.ac.za>       |\n".
         "| Advanced Information Management Laboratory   |\n".
         "| aim.cs.uct.ac.za :: University of Cape Town  |\n".
         "-----------------------------------------------+\n\n";
         
   if (! defined $ARGV[0])
   {
      print "Missing configuration name\n\n";
      print "Syntax: configure.pl <configname>\n\n";
      exit;
   }
   
   my $config = ReadConfig ($ARGV[0]);
   
   print "Defaults/previous values are in brackets - press <enter> to accept those\n".
         "enter \"&delete\" to erase a default value\n".
         "enter \"&continue\" to skip further questions and use all defaults\n".
         "press <ctrl>-c to escape at any time (new values will be lost)\n".
         "\nPress <enter> to continue\n\n";
         
   InputEnter;

         
   # get user information from system programs
   my $hostname = `hostname`; 
   my $username = `whoami`;
   if (defined $hostname)
   {
      $hostname =~ s/[\r\n\t\s]//go;
   }
   if (defined $username)
   {
      $username =~ s/[\n\r\t\s]//go;
   }
   my $creator = `finger $username | head -1 | cut -f 4 | cut -f 2- -d ':' | cut -d ' ' -f 2-`;
   if (defined $creator)
   {
      $creator =~ s/[\n\r]//go;
   }


   # Repository Name
   print "\n[REPOSITORY NAME]\n";
   print "For identification purposes, you need to specify the full name of\n".
         "the component\n".
         "Example: $ARGV[0] OAI Archive\n\n";
   do {
      InputLine (\$config->{'repositoryName'}->[0], "Enter your repository name");
   } while (InvalidInput (($config->{'repositoryName'}->[0] eq ''),
                          "This field cannot be left blank. Please enter a value."));
   

   # Admin Email
   print "\n[ADMINISTRATOR EMAIL]\n";
   print "When your archive is used by others, any problems\n".
         "will be reported to an administator, whose email must be provided\n".
         "Examples: admin\@oai.org, provost\@university.edu.\n\n";
   do {
      InputLine (\$config->{'adminEmail'}->[0], "Enter your administrator's email");
   } while (InvalidInput (($config->{'adminEmail'}->[0] !~ /^[^@]+@[^@\.]+\.(.+)/), 
                          "That doesnt seem to be in the right format. Please try again."));


   # Archive Id
   print "\n[ARCHIVE ID]\n";
   print "What is the archive identifier of this archive ?\n".
         "Examples: $hostname, $ARGV[0]\n\n";
   do {
      InputLine (\$config->{'archiveId'}->[0], "Archive ID");
   } while (InvalidInput (($config->{'archiveId'}->[0] eq ''),
                          "This field cannot be left blank. Please enter a value."));


   # Record Limit
   print "\n[RECORD LIMIT]\n";
   print "How many records should be issued before issuing a resumptiontoken ?\n".
         "Examples: 500 (default), 200\n\n";
   do {
      InputLine (\$config->{'recordlimit'}->[0], "Record limit");
   } while (InvalidInput (($config->{'recordlimit'}->[0] !~ /^[0-9]+$/),
                          "This field must be an unsigned integer. Please try again."));


   # Picture Directory
   print "\n[DATA DIRECTORY]\n";
   print "What is the directory that contains all the data files ?\n".
         "Examples: /home/$username/public_html/xmldata, data\n\n";
   do {
      InputLine (\$config->{'datadir'}->[0], "Data Directory");
   } while (InvalidInput (($config->{'datadir'}->[0] eq ''),
                          "This field cannot be left blank. Please enter a value."));


   # Long Identifiers
   print "\n[LONG IDENTIFIERS]\n";
   print "Do you want to use the full pathname as part of the identifiers ?\n".
         "Answer yes or no\n\n";
   do {
      InputLine (\$config->{'longids'}->[0], "Use long identifiers");
   } while (InvalidInput ((($config->{'longids'}->[0] ne 'yes') && ($config->{'longids'}->[0] ne 'no')),
                          "Please answer yes or no."));


   # File Matcher
   print "\n[FILE MATCH]\n";
   print "What is the regular expression that matches all files with actual metadata ?\n".
         "Examples: for .xml files (case insensitive): [^\.]+\.[xX][mM][lL]\$\n".
         "          for all files: .*\n".
         "          for .txt files: [^\.]+\.txt\$\n".
         "Enter an empty line to end and remember you can use &delete to delete an entry.\n\n";
   my $entry = 0;
   do {
      if ($#{$config->{'filematch'}} < $entry)
      {
         $config->{'filematch'}->[$entry] = '';
      }
      InputLine (\$config->{'filematch'}->[$entry], "File Match");
      $entry++;
   } while ($config->{'filematch'}->[$entry-1] ne '');
   

   # Multiple Set Membership
   print "\n[MULTIPLE SET MEMBERSHIP]\n";
   print "Do you want to allow items to exist in multiple sets\n".
         "(using symlinks or copies of the files) ?\n".
         "Note that this slows down generation of responses.\n".
         "Answer yes or no\n\n";
   do {
      InputLine (\$config->{'multiset'}->[0], "Use multi sets");
   } while (InvalidInput ((($config->{'multiset'}->[0] ne 'yes') && ($config->{'multiset'}->[0] ne 'no')),
                          "Please answer yes or no."));


   # Original Identifiers
   print "\n[ORIGINAL IDENTIFIERS]\n";
   print "Do you want to use the original filename without modification as the identifier?\n".
         "Answer yes or no\n\n";
   do {
      InputLine (\$config->{'originalids'}->[0], "Use original identifiers");
   } while (InvalidInput ((($config->{'originalids'}->[0] ne 'yes') && ($config->{'originalids'}->[0] ne 'no')),
                          "Please answer yes or no."));


   # Strip Extensions
   print "\n[STRIP EXTENSIONS]\n";
   print "Do you want to strip filename extensions from identifiers?\n".
         "Example: afilename.xml->afilename\n".
         "Answer yes or no\n\n";
   do {
      InputLine (\$config->{'stripextensions'}->[0], "Strip extensions");
   } while (InvalidInput ((($config->{'stripextensions'}->[0] ne 'yes') && ($config->{'stripextensions'}->[0] ne 'no')),
                          "Please answer yes or no."));


   # List Size Calculation
   print "\n[LIST SIZE CALCULATION]\n";
   print "Do you want to include the full listsize with each response ?\n".
         "Note that this slows down generation of responses.\n".
         "Answer yes or no\n\n";
   do {
      InputLine (\$config->{'listsize'}->[0], "Calculate list size");
   } while (InvalidInput ((($config->{'listsize'}->[0] ne 'yes') && ($config->{'listsize'}->[0] ne 'no')),
                          "Please answer yes or no."));


   # Metadata configuration
   my $choice;
   print "\n[METADATA FORMATS]\n";
   print "Add all the metadata formats supported by this archive\n";
   do {
      # print out metadata listing
      print "\nCurrent list of metadata formats (prefix, ns, schema, transform):\n";
      if ($#{$config->{'metadata'}} == -1)
      {
         print "No formats currently defined !\n";
      }
      for ( my $i=0; $i<=$#{$config->{'metadata'}}; $i++ )
      {
         my $metadata = $config->{'metadata'}->[$i];
         print "$i. ".$metadata->{'prefix'}->[0].' '.$metadata->{'namespace'}->[0].
               ' '.$metadata->{'schema'}->[0].' '.$metadata->{'transform'}->[0]."\n";
      }
      
      # print out menu
      my $instrline = "\nSelect from: [A]dd   [R]emove   [E]dit   [D]one\n";
      if ($#{$config->{'metadata'}} == -1)
      {
         $instrline = "\nSelect from: [A]dd   [D]one\n";
      }
      print $instrline;

      # get choice
      do {
         $choice = 'D';
         InputLine (\$choice, "Enter your choice");
         $choice = uc ($choice);
      } while (InvalidInput (((($choice !~ /^[ARED]$/) || ($#{$config->{'metadata'}} == -1)) &&
                              (($choice !~ /^[AD]$/) || ($#{$config->{'metadata'}} > -1))),
                             $instrline));

      # act on choice
      if ($choice eq 'A')
      {
         push (@{$config->{'metadata'}}, { prefix => [''], namespace => [''], 
           schema => [''], transform => [''],
           mdorder => [ qw ( prefix namespace schema transform ) ] } );
         metadata_config ($config->{'metadata'}->[-1]);
      }
      elsif (($choice eq 'E') || ($choice eq 'R'))
      {
         my $metadatano = '';
         do {
            InputLine (\$metadatano, "Enter the number of the format");
         } while (InvalidInput ((($metadatano !~ /^[0-9]+$/) || ($metadatano > $#{$config->{'metadata'}})),
                                "This has to be an integer in the range listed. Please try again."));
         
         if ($choice eq 'R')
         {
            my $confirm = 'Y/N';
            do {
               InputLine (\$confirm, "Confirm");
               $confirm = uc ($confirm);
            } while (InvalidInput (($confirm !~ /^[NY]$/),
                                   "Enter Y or N"));
            if ($confirm eq 'Y')
            {
               splice (@{$config->{'metadata'}}, $metadatano, 1);
            }
         }
         elsif ($choice eq 'E')
         {
            metadata_config ($config->{'metadata'}->[$metadatano]);
         }
      }
      
   } while ($choice ne 'D');


   WriteConfig ($config, $ARGV[0]);
   
   print "\n\n\nFinis.\n\n";
   
   print "Now you are ready to use the OAI 2 XMLFile v2.2 interface\n".
         "Use $ARGV[0]/oai.pl as the last bit of the baseURL for the archive interface\n\n";
}

main;
