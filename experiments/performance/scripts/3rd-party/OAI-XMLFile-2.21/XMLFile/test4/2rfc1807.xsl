<xsl:stylesheet version='1.0'
 xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
 xmlns:oaidc='http://www.openarchives.org/OAI/2.0/oai_dc/'
 xmlns:dc='http://purl.org/dc/elements/1.1/' 
 xmlns:rfc1807="http://info.internet.isi.edu:80/in-notes/rfc/files/rfc1807.txt"
 xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
>

<!-- 

   Convert dc or rfc1807 to rfc1807
   Hussein Suleman
   1 july 2002
   Virginia Tech DLRL

-->


   <xsl:output method="xml"/>
   
   <xsl:template match="rfc1807:rfc1807">
      <rfc1807:rfc1807 xsi:schemaLocation="http://info.internet.isi.edu:80/in-notes/rfc/files/rfc1807.txt http://www.openarchives.org/OAI/1.1/rfc1807.xsd">
         <rfc1807:bib-version>1</rfc1807:bib-version>
         <rfc1807:id><xsl:value-of select="rfc1807:id"/></rfc1807:id>
         <xsl:for-each select="rfc1807:entry">
            <rfc1807:entry><xsl:value-of select="."/></rfc1807:entry>
         </xsl:for-each>
         <xsl:for-each select="rfc1807:title">
            <rfc1807:title><xsl:value-of select="."/></rfc1807:title>
         </xsl:for-each>
         <xsl:for-each select="rfc1807:other_access">
            <rfc1807:other_access><xsl:value-of select="."/></rfc1807:other_access>
         </xsl:for-each>
      </rfc1807:rfc1807>
   </xsl:template>

   <xsl:template match="oaidc:dc">
      <rfc1807:rfc1807 xsi:schemaLocation="http://info.internet.isi.edu:80/in-notes/rfc/files/rfc1807.txt http://www.openarchives.org/OAI/1.1/rfc1807.xsd">
         <rfc1807:bib-version>1</rfc1807:bib-version>
         <rfc1807:id>no_id</rfc1807:id>
         <xsl:for-each select="dc:date">
            <rfc1807:entry><xsl:value-of select="."/></rfc1807:entry>
         </xsl:for-each>
         <xsl:for-each select="dc:title">
            <rfc1807:title><xsl:value-of select="."/></rfc1807:title>
         </xsl:for-each>
         <xsl:for-each select="dc:identifier">
            <rfc1807:other_access><xsl:value-of select="concat ('url:', .)"/></rfc1807:other_access>
         </xsl:for-each>
      </rfc1807:rfc1807>
   </xsl:template>

</xsl:stylesheet> 

