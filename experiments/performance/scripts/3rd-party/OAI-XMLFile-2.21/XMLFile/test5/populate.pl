#!/usr/bin/perl

for ( my $i=2; $i<=3000; $i++ )
{
   system ("cp data/dc1.xml data/dc$i.xml");
}
