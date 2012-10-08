#  ---------------------------------------------------------------------
#   Test Archive - OAI 2 data provider
#    v1.0
#    June 2002
#  ------------------+--------------------+-----------------------------
#   Hussein Suleman  |   hussein@vt.edu   |    www.husseinsspace.com    
#  ------------------+--------------------+-+---------------------------
#   Department of Computer Science          |        www.cs.vt.edu       
#     Digital Library Research Laboratory   |       www.dlib.vt.edu      
#  -----------------------------------------+-------------+-------------
#   Virginia Polytechnic Institute and State University   |  www.vt.edu  
#  -------------------------------------------------------+-------------


package Test::TestDP;


use Pure::EZXML;
use Pure::X2D;

use OAI::OAI2DP;
use vars ('@ISA');
@ISA = ("OAI::OAI2DP");


# constructor
sub new
{
   my ($classname) = @_;
   my $self = $classname->SUPER::new ();

   # set configuration
   $self->{'repositoryName'} = 'Test Archive';
   $self->{'archiveId'} = 'test';
   
   bless $self, $classname;
   return $self;
}


# destructor
sub dispose
{
   my ($self) = @_;
   $self->SUPER::dispose ();
}


# format DC record
sub FormatDC
{
   my ($self, $hashref) = @_;

   {
      title       => $hashref->{'title'},
      identifier  => $hashref->{'identifier'},
      mdorder     => [ qw (title creator subject description contributor publisher date type format identifier source language relation coverage rights) ]
   };
}


# format header for ListIdentifiers
sub Archive_FormatHeader
{
   my ($self, $hashref, $metadataFormat) = @_;
   
   $self->FormatHeader ($hashref->{'urn'},
                        $hashref->{'updatedate'},
                        '',
                        [ 'testset' ]
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

   my $dc = $self->FormatDC ($hashref);
   
   my $header = "<oaidc:dc xmlns=\"http://purl.org/dc/elements/1.1/\" ".
                "xmlns:oaidc=\"http://www.openarchives.org/OAI/2.0/oai_dc/\" ".
                "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" ".
                "xsi:schemaLocation=\"http://www.openarchives.org/OAI/2.0/oai_dc/ ".
                "http://www.openarchives.org/OAI/2.0/oai_dc.xsd\">\n";
   my $footer = "</oaidc:dc>\n";

   $self->FormatRecord ($hashref->{'urn'},
                        $hashref->{'updatedate'},
                        '',
                        [ 'testset' ],
                        $header.$self->{'utility'}->FormatXML ($dc).$footer,
                        '',
                       );
}


# get full list of mdps or list for specific identifier
sub Archive_ListMetadataFormats
{
   my ($self, $identifier) = @_;
   
   if ((! defined $identifier) || ($identifier eq ''))
   {
      return [];
   }
   
   if (($identifier ne 'oai:test:1') && ($identifier ne 'oai:test:2'))
   {
      $self->AddError ('idDoesNotExist', 'The value of the identifier argument is unknown or illegal in this repository');
   }
   return [];
}


# get full list of sets from the archive
sub Archive_ListSets
{
   [ [ 'testset', 'Test Set Name' ] ];
}
                              

# get a single record from the archive
sub Archive_GetRecord
{
   my ($self, $identifier, $metadataFormat) = @_;

   if ($identifier eq 'oai:test:1')
   {
      {
         urn                => 'oai:test:1',
         title              => 'OAI website',
         updatedate         => '2002-06-11',
         identifier         => 'http://www.openarchives.org',
      }
   }
   elsif ($identifier eq 'oai:test:2')
   {
      {
         urn                => 'oai:test:2',
         title              => 'VT-DLRL website',
         updatedate         => '2002-06-11',
         identifier         => 'http://www.dlib.vt.edu',
      }
   }
   else
   {
      $self->AddError ('idDoesNotExist', 'The value of the identifier argument is unknown or illegal in this repository');
      undef;
   }
}


# list metadata records from the archive
sub Archive_ListRecords
{
   my ($self, $set, $from, $until, $metadataPrefix, $resumptionToken) = @_;

   my @allrows = ();

   if ((($set eq '') || ($set eq 'testset')) &&
       (($from eq '') || ($self->ToSeconds ('2002-06-11') >= $self->ToSeconds ($from, 1))) &&
       (($until eq '') || ($self->ToSeconds ('2002-06-11') <= $self->ToSeconds ($until))))
   {
      @allrows = (
         {
            urn                => 'oai:test:1',
            title              => 'OAI website',
            updatedate         => '2002-06-11',
            identifier         => 'http://www.openarchives.org',
         },
         {
            urn                => 'oai:test:2',
            title              => 'VT-DLRL website',
            updatedate         => '2002-06-11',
            identifier         => 'http://www.dlib.vt.edu',
         },
      );
   }
   else
   {
      $self->AddError ('noRecordsMatch', 'The combination of the values of arguments results in an empty set');
   }

   ( \@allrows, '', $metadataPrefix, {} );
}


# list identifiers (headers) from the archive
sub Archive_ListIdentifiers
{
   my ($self, $set, $from, $until, $metadataPrefix, $resumptionToken) = @_;

   if (($metadataPrefix ne '') && ($self->MetadataFormatisValid ($metadataPrefix) == 0))
   {
      $self->AddError ('cannotDisseminateFormat', 'The value of metadataPrefix is not supported by the repository');
      return '';
   }
   
   $self->Archive_ListRecords ($set, $from, $until, $metadataPrefix, $resumptionToken);
}


1;

