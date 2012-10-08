<xsl:stylesheet version='1.0'
 xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
 xmlns:oaidc='http://www.openarchives.org/OAI/2.0/oai_dc/'
 xmlns:dc='http://purl.org/dc/elements/1.1/' 
 xmlns:rfc1807="http://info.internet.isi.edu:80/in-notes/rfc/files/rfc1807.txt"
 xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
>

<!-- 

   Convert dc or rfc1807 to dc
   Hussein Suleman
   1 july 2002
   Virginia Tech DLRL

-->


   <xsl:output method="xml"/>
   
   <xsl:template match="rfc1807:rfc1807">
      <oaidc:dc xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
         <xsl:for-each select="rfc1807:title">
            <dc:title><xsl:value-of select="."/></dc:title>
         </xsl:for-each>
         <xsl:for-each select="rfc1807:other_access">
            <dc:identifier><xsl:value-of select="substring (., 5)"/></dc:identifier>
         </xsl:for-each>
         <xsl:for-each select="rfc1807:entry">
            <dc:date><xsl:value-of select="."/></dc:date>
         </xsl:for-each>
      </oaidc:dc>
   </xsl:template>

   <xsl:template match="oaidc:dc">
      <oaidc:dc xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
         <xsl:for-each select="dc:title">
            <dc:title><xsl:value-of select="."/></dc:title>
         </xsl:for-each>
         <xsl:for-each select="dc:identifier">
            <dc:identifier><xsl:value-of select="."/></dc:identifier>
         </xsl:for-each>
         <xsl:for-each select="dc:date">
            <dc:date><xsl:value-of select="."/></dc:date>
         </xsl:for-each>
      </oaidc:dc>
   </xsl:template>

</xsl:stylesheet> 

