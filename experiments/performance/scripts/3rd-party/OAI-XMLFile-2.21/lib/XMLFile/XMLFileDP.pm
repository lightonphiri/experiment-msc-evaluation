# +---------------------------------------------------------------------+
#    XMLFile OAI-PMH data provider
#    v2.21
#    August 2005
# +----------------------------------+----------------------------------+
# |  Hussein Suleman                 |  Department of Computer Science  |
# |   <hussein@cs.uct.ac.za>         |  University of Cape Town         |
# |   http://www.husseinsspace.com   |  Cape Town, South Africa         |
# +----------------------------------+----------------------------------+


package XMLFile::XMLFileDP;


use Pure::EZXML;
use Pure::X2D;

use OAI::OAI2DP;
use vars ('@ISA');
@ISA = ("OAI::OAI2DP");


# constructor
sub new
{
   my ($classname, $configfile) = @_;
   my $self = $classname->SUPER::new ($configfile);

   # get configuration from file
   my $con = new Pure::X2D ($configfile);
   $self->{'repositoryName'} = $con->param ('repositoryName', 'XML-File Archive');
   $self->{'adminEmail'} = $con->param ('adminEmail', "someone\@somewhere");
   $self->{'archiveId'} = $con->param ('archiveId', 'XMLFileArchive');
   $self->{'recordlimit'} = $con->param ('recordlimit', 500);
   $self->{'datadir'} = $con->param ('datadir', 'data');
   $self->{'longids'} = $con->param ('longids', 'no');
   $self->{'filematch'} = $con->{'filematch'};
   $self->{'metadata'} = $con->{'metadata'};
   $self->{'multiset'} = $con->param ('multiset', 'no');
   $self->{'listsize'} = $con->param ('listsize', 'no');
   $self->{'originalids'} = $con->param ('originalids', 'no');
   if ($self->{'originalids'} eq 'yes')
   { $self->{'stripextensions'} = $con->param ('stripextensions', 'no'); }
   else
   { $self->{'stripextensions'} = $con->param ('stripextensions', 'yes'); }

   $self->{'setnamefile'} = $con->param ('setnamefile', '_name_');
   $self->{'setdescriptionfile'} = $con->param ('setdescriptionfile', '_description_');
   $self->{'resumptionseparator'} = '!';
   
   # remove default metadata information
   $self->{'metadatanamespace'} = {};
   $self->{'metadataschema'} = {};
   $self->{'metadatatransform'} = {};

   # add in seconds support
   $self->{'granularity'} = 'YYYY-MM-DDThh:mm:ssZ';
   $self->{'earliestDatestamp'} = '1970-01-01T00:00:00Z';
   
   # add in metadata formats from list in configuration
   foreach my $metadata (@{$con->{'metadata'}})
   {
      my $metadataPrefix = $metadata->{'prefix'}->[0];
      $self->{'metadatanamespace'}->{$metadataPrefix} = $metadata->{'namespace'}->[0];
      $self->{'metadataschema'}->{$metadataPrefix} = $metadata->{'schema'}->[0];
      if (defined $metadata->{'transform'}->[0])
      {
         $self->{'metadatatransform'}->{$metadataPrefix} = $metadata->{'transform'}->[0];
      }
      else
      {
         $self->{'metadatatransform'}->{$metadataPrefix} = '';
      }
   }

   # load in set mappings
   $self->{'setnames'} = {};
   if (-e 'setnames.xml')
   {
      my $parser = new Pure::EZXML;
      my $setnamedoc = $parser->parsefile ('setnames.xml')->getDocumentElement;
      
      foreach my $set ($setnamedoc->getElementsByTagName ('set'))
      {
         my $spec = $set->getElementsByTagName ('spec', 0)->item(0)->getChildNodes->toString;
         my $name = $set->getElementsByTagName ('name', 0)->item(0)->getChildNodes->toString;
         if ((defined $spec) && (defined $name))
         {
            $self->{'setnames'}->{$spec} = $name;
         }
      }
   }

   bless $self, $classname;
   return $self;
}


# destructor
sub dispose
{
   my ($self) = @_;
   $self->SUPER::dispose ();
}


# database: list all sets
sub db_list_sets
{
   my ($self, $directory) = @_;
   my $setlist = {};
   
   # initialise directory parameter
   if (! defined $directory)
   { $directory = ''; }

   # go through each entry in the current directory
   opendir (my $dir, "$self->{'datadir'}$directory");
   while ( my $afile = readdir ($dir) )
   {
      # skip the directory markers
      if (($afile eq '.') || ($afile eq '..'))
      { next; }

      # if its a directory ...
      if (-d "$self->{'datadir'}$directory/$afile")
      {
         # create set name
         my $mainset = $directory;
         if ($mainset ne '')
         {
            $mainset = substr ($mainset, 1);
            $mainset =~ s/\//:/go;
            $mainset .= ':';
         }
         
         my ($setname, $setdescription) = ($mainset.$afile, undef);
         
         # add in set name if it exists
         if (-e "$self->{'datadir'}$directory/$afile/$self->{'setnamefile'}")
         {
            open ($file, "$self->{'datadir'}$directory/$afile/$self->{'setnamefile'}");
            $setname = <$file>;
            close ($file);
            
            if (defined $setname)
            { chomp $setname; }
            else
            { $setname = $mainset.$afile; }
         }
         if (exists $self->{'setnames'}->{$mainset.$afile})
         {
            $setname = $self->{'setnames'}->{$mainset.$afile};
         }
         
         # add in set description if it exists
         if (-e "$self->{'datadir'}$directory/$afile/$self->{'setdescriptionfile'}")
         {
            open ($file, "$self->{'datadir'}$directory/$afile/$self->{'setdescriptionfile'}");
            while (my $aline = <$file>) 
            { $setdescription .= $aline; };
            close ($file);
         }
         
         $setlist->{$mainset.$afile} = [ $setname, $setdescription ];

         my $partiallist = $self->db_list_sets ("$directory/$afile");
         foreach my $key (keys %$partiallist)
         {
            $setlist->{$key} = $partiallist->{$key};
         }
      }
   }
   closedir ($dir);
   
   return $setlist;
}


# database: get a single record from the collection
sub db_get_record
{
   my ($self, $checkidentifier, $directory) = @_;
   my $record = { datestamp=>'', sets=>[], pathname=>'', identifier=>$checkidentifier };
   
   # initialise directory parameter
   if (! defined $directory)
   { $directory = ''; }

   # go through each entry in the current directory
   opendir (my $dir, "$self->{'datadir'}$directory");
   while ( my $afile = readdir ($dir) )
   {
      # skip the directory markers
      if (($afile eq '.') || ($afile eq '..'))
      { next; }
   
      # skip the special files for set descriptions/names
      if (($afile eq $self->{'setnamefile'}) || ($afile eq $self->{'setdescriptionfile'}))
      { next; }

      # if its a directory ...
      if (-d "$self->{'datadir'}$directory/$afile")
      {
         # get record if it exists in descendent directories and add to current
         my $partial_record = $self->db_get_record ($checkidentifier, "$directory/$afile");
         if (defined $partial_record)
         {
            # add datestamp only if newer - add sets anyway
            if ($partial_record->{'datestamp'} gt $record->{'datestamp'})
            {
               $record->{'datestamp'} = $partial_record->{'datestamp'};
               $record->{'pathname'} = $partial_record->{'pathname'};
            }
            push (@{$record->{'sets'}}, @{$partial_record->{'sets'}});
            
            # short circuit if no more matching needed
            if ($self->{'multiset'} eq 'no')
            { 
               closedir ($dir);
               return $record; 
            }
         }
      }

      # if its a file ...
      elsif (-f "$self->{'datadir'}$directory/$afile")
      {
         # screen out for files that do not match
         my $good = 0;
         foreach my $filematch (@{$self->{'filematch'}})
         {
            if ($afile =~ /$filematch/o)
            {
               $good = 1;
            }
         }
         if (($good == 0) || ($afile eq $self->{'setnamefile'}) || ($afile eq $self->{'setdescriptionfile'}))
         {
            next;
         }
      
         # create identifier
         my $identifier = $afile;
         if (($self->{'stripextensions'} eq 'yes') && (rindex ($afile, '.') > -1))
         { $identifier = substr ($afile, 0, rindex ($afile, '.')); }
         if ($self->{'originalids'} eq 'no')
         {
            if ($self->{'longids'} eq 'no')
            { $identifier = 'oai:'.$self->{'archiveId'}.':'.$identifier; }
            else
            { $identifier = 'oai:'.$self->{'archiveId'}.':'.substr ($directory.'/', 1).$identifier; }
         }

         # test for matching identifier
         if ($identifier eq $checkidentifier)
         {
            # create full datestamp for file
            my $date = (stat("$self->{'datadir'}$directory/$afile"))[9];
            my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime ($date);
            my $datestamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02dZ", $year+1900, $mon+1, $mday, $hour, $min, $sec);
         
            # create set spec and add to record information
            my $mainset = $directory;
            if ($mainset ne '')
            {
               $mainset = substr ($mainset, 1);
               $mainset =~ s/\//:/go;
               push (@{$record->{'sets'}}, $mainset);
            }
            
            # if it is newer, add in the record information
            if ($datestamp gt $record->{'datestamp'})
            {
               $record->{'datestamp'} = $datestamp;
               $record->{'pathname'} = "$directory/$afile";
            }
            
            # short circuit if no more matching needed
            if ($self->{'multiset'} eq 'no')
            { 
               closedir ($dir);
               return $record; 
            }
         }
      }
   }
   closedir ($dir);
   
   if ($record->{'datestamp'} ne '')
   { return $record; }
   else
   { return undef; }
}


# database: fill in sets for multiset records in a listrecords response
sub db_fill_in_sets
{
   my ($self, $allrecords, $directory) = @_;
   
   # initialise running parameters
   if (! defined $directory)
   { $directory = ''; }
   
   # go through each file in current directory
   opendir (my $dir, "$self->{'datadir'}$directory");
   while ( my $afile = readdir ($dir) )
   {
      # skip the directory markers
      if (($afile eq '.') || ($afile eq '..'))
      { next; }
   
      # skip the special files for set descriptions/names
      if (($afile eq $self->{'setnamefile'}) || ($afile eq $self->{'setdescriptionfile'}))
      { next; }

      # if its a directory ...
      if (-d "$self->{'datadir'}$directory/$afile")
      { 
         $self->db_fill_in_sets ($allrecords, "$directory/$afile");
      }

      # if its a file ...
      elsif (($directory ne '') && (-f "$self->{'datadir'}$directory/$afile"))
      {
         # screen out for files that do not match
         my $good = 0;
         foreach my $filematch (@{$self->{'filematch'}})
         {
            if ($afile =~ /$filematch/o)
            { $good = 1; }
         }
         if (($good == 0) || ($afile eq $self->{'setnamefile'}) || ($afile eq $self->{'setdescriptionfile'}))
         { next; }
      
         # create identifier
         my $identifier = $afile;
         if (rindex ($afile, '.') > -1)
         { $identifier = substr ($afile, 0, rindex ($afile, '.')); }
         if ($self->{'originalids'} eq 'no')
         {
            if ($self->{'longids'} eq 'no')
            { $identifier = 'oai:'.$self->{'archiveId'}.':'.$identifier; }
            else
            { $identifier = 'oai:'.$self->{'archiveId'}.':'.substr ($directory.'/', 1).$identifier; }
         }
         
         # fill in sets
         foreach my $record (@$allrecords)
         {
            if ($record->{'identifier'} eq $identifier)
            {
               my $mainset = $directory;
               if ($mainset ne '')
               {
                  $mainset = substr ($mainset, 1);
                  $mainset =~ s/\//:/go;
               }
               push (@{$record->{'sets'}}, $mainset);
            }
         }
      }
   }
   closedir ($dir);
}


# database: list a subset of records from the collection
sub db_list_records
{
   my ($self, $set, $from, $until, $offset, $directory, $count, $gotmore, $allrecords, $identifiers) = @_;

   # initialise running parameters
   my $first = 0;
   if (! defined $directory)
   {
      $directory = '';
      if ($set ne '')
      {
         $directory = '/'.$set;
         $directory =~ s/:/\//go;
      }
      $gotmore = 0;
      $allrecords = [];
      $identifiers = {};
      $count = 0;
      $first = 1;
   }

   # go through contents of current directory
   opendir (my $dir, "$self->{'datadir'}$directory");
   while ( my $afile = readdir ($dir))
   {
      # skip the directory markers
      if (($afile eq '.') || ($afile eq '..'))
      { next; }
      
      # skip the special files for set descriptions/names
      if (($afile eq $self->{'setnamefile'}) || ($afile eq $self->{'setdescriptionfile'}))
      { next; }
   
      # if its a directory ...
      if (-d "$self->{'datadir'}$directory/$afile")
      {
         ($allrecords, $count, $gotmore) = 
            $self->db_list_records ($set, $from, $until, $offset, "$directory/$afile", $count, $gotmore, $allrecords, $identifiers);
         if (($gotmore == 1) && ($self->{'listsize'} eq 'no'))
         { 
            closedir ($dir);
            return ($allrecords, $count, $gotmore); 
         }
      }

      # if its a file ...
      elsif (-f "$self->{'datadir'}$directory/$afile")
      {
         # screen out for files that do not match
         my $good = 0;
         foreach my $filematch (@{$self->{'filematch'}})
         {
            if ($afile =~ /$filematch/o)
            { $good = 1; }
         }
         if (($good == 0) || ($afile eq $self->{'setnamefile'}) || ($afile eq $self->{'setdescriptionfile'}))
         { next; }
      
         # create identifier
         my $identifier = $afile;
         if (($self->{'stripextensions'} eq 'yes') && (rindex ($afile, '.') > -1))
         { $identifier = substr ($afile, 0, rindex ($afile, '.')); }
         if ($self->{'originalids'} eq 'no')
         {
            if ($self->{'longids'} eq 'no')
            { $identifier = 'oai:'.$self->{'archiveId'}.':'.$identifier; }
            else
            { $identifier = 'oai:'.$self->{'archiveId'}.':'.substr ($directory.'/', 1).$identifier; }
         }
         
         # skip over multiset identifiers
         if ($self->{'multiset'} ne 'no')
         {
            if (exists $identifiers->{$identifier})
            { next; }
            $identifiers->{$identifier} = 1;
         }
         
         # create full datestamp for file
         my $date = (stat("$self->{'datadir'}$directory/$afile"))[9];
         my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime ($date);
         my $datestamp = sprintf ("%04d-%02d-%02dT%02d:%02d:%02dZ", $year+1900, $mon+1, $mday, $hour, $min, $sec);
         
         # check range criteria and gather records
         if ((($from eq '') || ($self->ToSeconds ($datestamp) >= $self->ToSeconds ($from, 1))) &&
             (($until eq '') || ($self->ToSeconds ($datestamp) <= $self->ToSeconds ($until))))
         {
            $count++;
            if ($count > $offset)
            {
               if ($count <= $offset+$self->{'recordlimit'}) 
               {
                  # add in sets for non-multiset records
                  my $sets = [];
                  if ($self->{'multiset'} eq 'no')
                  {
                     my $mainset = $directory;
                     if ($mainset ne '')
                     {
                        $mainset = substr ($mainset, 1);
                        $mainset =~ s/\//:/go;
                        $sets = [ $mainset ];
                     }
                  }
                  push (@$allrecords, { identifier=>$identifier, datestamp=>$datestamp, sets=>$sets, pathname=>"$directory/$afile" });
               }
               else
               {
                  if ($self->{'listsize'} eq 'yes')
                  {
                     $gotmore = 1;
                  }
                  else
                  {
                     # fill in multisets if this is outermost nest
                     if ($self->{'multiset'} ne 'no')
                     { $self->db_fill_in_sets ($allrecords); }

                     closedir ($dir);
                     return ($allrecords, $count, 1);
                  }
               }
            }
         }
      }
   }
   closedir ($dir);
   
   # fill in multisets if this is outermost nest
   if (($first == 1) && ($self->{'multiset'} ne 'no'))
   { $self->db_fill_in_sets ($allrecords); }
   
   ($allrecords, $count, $gotmore);
}


# format header for ListIdentifiers
sub Archive_FormatHeader
{
   my ($self, $hashref, $metadataFormat) = @_;
   
   $self->FormatHeader ($hashref->{'identifier'},
                        $hashref->{'datestamp'},
                        '',
                        $hashref->{'sets'}
                       );
}


# retrieve records from the source archive as required
sub Archive_FormatRecord
{
   my ($self, $hashref, $metadataFormat) = @_;
   
   if ($self->MetadataFormatisValid ($metadataFormat) == 0)
   {
      $self->AddError ('cannotDisseminateFormat', 'The value of metadataPrefix is not supported by the repository');
      return '';
   }

   # get data file and tranform accordingly
   my $pathname = $hashref->{'pathname'};
   my $metadataTransform = $self->{'metadatatransform'}->{$metadataFormat};
   my $file;
   if ($metadataTransform eq '')
   {
      open ($file, "$self->{'datadir'}$pathname");
   }
   else
   {
      open ($file, "cat $self->{'datadir'}$pathname | $metadataTransform");
   }
   my @data = <$file>;
   close ($file);
   my $fstr = join ('', @data);

   # get rid of XML declaration
   $fstr =~ s/^<\?[^\?]+\?>//o;

   $self->FormatRecord ($hashref->{'identifier'},
                        $hashref->{'datestamp'},
                        '',
                        $hashref->{'sets'},
                        $fstr,
                        '',
                       );
}


# add additional information into the identification
sub Archive_Identify
{
   my ($self) = @_;
   
   my $identity = {};
   
   # add in description for toolkit
   if (! exists $identity->{'description'})
   {
      $identity->{'description'} = [];
   }
   my $desc = {
      'toolkit' => [[
         {
            'xmlns' => 'http://oai.dlib.vt.edu/OAI/metadata/toolkit',
            'xsi:schemaLocation' =>
                       'http://oai.dlib.vt.edu/OAI/metadata/toolkit '.
                       'http://oai.dlib.vt.edu/OAI/metadata/toolkit.xsd'
         },
         {
            'title'    => 'XML-File Data Provider',
            'author'   => {
               'name' => 'Hussein Suleman',
               'email' => 'hussein@cs.uct.ac.za',
               'institution' => 'University of Cape Town',
               'mdorder' => [ qw ( name email institution ) ],
            },
            'version'  => '2.21',
            'URL'      => 'http://simba.cs.uct.ac.za/projects/xmlfile/',
            'mdorder'  => [ qw ( title author version URL ) ]
         }
      ]]
   };
   push (@{$identity->{'description'}}, $desc);
   
   # add in external description containers
   opendir (my $dir, ".");
   my @files = readdir ($dir);
   closedir ($dir);

   foreach my $identityfile (grep { /^identity[^\.]*\.xml$/ } @files)
   {
      open (my $file, "$identityfile");
      my @data = <$file>;
      close ($file);
      
      my $joineddata = join ('', @data);

      # get rid of XML declaration
      $joineddata =~ s/^<\?[^\?]+\?>//o;
      
      push (@{$identity->{'description'}}, $joineddata );
   }
   
   $identity;
}


# get full list of mdps or list for specific identifier
sub Archive_ListMetadataFormats
{
   my ($self, $identifier) = @_;
   
   if ((defined $identifier) && ($identifier ne '') && (! defined $self->db_get_record ($identifier)))
   {
      $self->AddError ('idDoesNotExist', 'The value of the identifier argument is unknown or illegal in this repository');
   }
   return [];
}


# get full list of sets from the archive
sub Archive_ListSets
{
   my ($self) = @_;

   my $setlist = $self->db_list_sets;

   [
      map {
         [ $_, $setlist->{$_}->[0], $setlist->{$_}->[1] ]
      } keys %$setlist
   ];
}
                              

# get a single record from the archive
sub Archive_GetRecord
{
   my ($self, $identifier, $metadataFormat) = @_;
   
   my $record = $self->db_get_record ($identifier);
   
   if (! defined $record)
   {
      $self->AddError ('idDoesNotExist', 'The value of the identifier argument is unknown or illegal in this repository');
      return undef;
   }

   return $record;
}


# list all records in the archive
sub Archive_ListRecords
{
   my ($self, $set, $from, $until, $metadataPrefix, $resumptionToken) = @_;

   # handle resumptionTokens
   my ($offset);
   if ($resumptionToken eq '')
   {
      $offset = 0;
   }
   else
   {
      my @rdata = split ($self->{'resumptionseparator'}, $resumptionToken);
      ($set, $from, $until, $metadataPrefix, $offset) = @rdata;
      if ((! defined $set) || (! defined $from) || (! defined $until) ||
          (! defined $metadataPrefix) || (! defined $offset))
      {
         $self->AddError ('badResumptionToken', 'The resumptionToken is not in the correct format');
         return '';
      }
   }

   # check for existence of set
   if ($set ne '')
   {
      my $setlist = $self->db_list_sets;
      if (! defined $setlist->{$set})
      {
         $self->AddError ('badArgument', 'The specified set does not exist');
         return '';
      }
   }
   
   # get a new subset of identifiers
   my ($allrows, $count, $gotmore) = $self->db_list_records ($set, $from, $until, $offset);

   # create a new resumptionToken, and its parameters, if necessary
   $resumptionToken = '';
   if ($gotmore == 1)
   {
      $resumptionToken = join ($self->{'resumptionseparator'}, ($set,$from,$until,$metadataPrefix,$offset+$self->{'recordlimit'}));
   }
   if ($count == 0)
   {
      $self->AddError ('noRecordsMatch', 'The combination of the values of arguments results in an empty set');
   }
   my $tokenParameters = {};
   if ($resumptionToken ne '')
   {
      $tokenParameters = { 'cursor' => $offset };
      if ($self->{'listsize'} ne 'no')
      {
         $tokenParameters->{'completeListSize'} = $count;
      }
   }

   ( $allrows, $resumptionToken, $metadataPrefix, $tokenParameters );
}


# list headers for all records in the archive
sub Archive_ListIdentifiers
{
   my ($self, $set, $from, $until, $metadataPrefix, $resumptionToken) = @_;

   # check for metadataPrefix if it is provided
   if ((defined $metadataPrefix) && ($metadataPrefix ne '') && ($self->MetadataFormatisValid ($metadataPrefix) == 0))
   {
      $self->AddError ('cannotDisseminateFormat', 'The value of metadataPrefix is not supported by the repository');
      return '';
   }
   
   $self->Archive_ListRecords ($set, $from, $until, $metadataPrefix, $resumptionToken);
}


1;

