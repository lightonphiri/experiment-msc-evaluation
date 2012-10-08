<xsl:stylesheet version='1.0'
 xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
 xmlns:oaidc='http://www.openarchives.org/OAI/2.0/oai_dc/'
 xmlns:dc='http://purl.org/dc/elements/1.1/' 
 xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
>

<!-- 

   Proprietary Qualified DC to PMH2 OAI_DC transformation
   Hussein Suleman
    for AmericanSouth.org
   29 june 2002
   Virginia Tech DLRL

-->


   <xsl:output method="xml"/>

   <xsl:template match="dc">
      <oaidc:dc xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
         <xsl:for-each select="DC.Title">
            <dc:title><xsl:value-of select="."/></dc:title>
         </xsl:for-each>
         <xsl:for-each select="DC.Creator.Corporate | DC.Creator.PersonalName | DC.Creator.Address | DC.Creator.CorporateName | DC.Creator.CorporateAddress">
            <dc:creator><xsl:value-of select="."/></dc:creator>
         </xsl:for-each>
         <xsl:for-each select="DC.Subject">
            <dc:subject><xsl:value-of select="."/></dc:subject>
         </xsl:for-each>
         <xsl:for-each select="DC.Description">
            <dc:description><xsl:value-of select="."/></dc:description>
         </xsl:for-each>
         <xsl:for-each select="DC.Publisher | DC.Publisher.Address">
            <dc:publisher><xsl:value-of select="."/></dc:publisher>
         </xsl:for-each>
         <xsl:for-each select="DC.Type">
            <dc:type><xsl:value-of select="."/></dc:type>
         </xsl:for-each>
         <xsl:for-each select="DC.Identifier.URI | DC.Identifier.URN">
            <dc:identifier><xsl:value-of select="."/></dc:identifier>
         </xsl:for-each>
         <xsl:for-each select="DC.Source">
            <dc:source><xsl:value-of select="."/></dc:source>
         </xsl:for-each>
         <xsl:for-each select="DC.Language.ISO639-1">
            <dc:language><xsl:value-of select="."/></dc:language>
         </xsl:for-each>
         <xsl:for-each select="DC.Date.ISO8601">
            <dc:date><xsl:value-of select="."/></dc:date>
         </xsl:for-each>
         <xsl:for-each select="DC.Rights">
            <dc:rights><xsl:value-of select="."/></dc:rights>
         </xsl:for-each>
         
         <xsl:for-each select="DC.Subject">
            <dc:subject><xsl:value-of select="."/></dc:subject>
         </xsl:for-each>
         <xsl:for-each select="DC.Subject">
            <dc:subject><xsl:value-of select="."/></dc:subject>
         </xsl:for-each>
         <xsl:for-each select="DC.Subject">
            <dc:subject><xsl:value-of select="."/></dc:subject>
         </xsl:for-each>
      </oaidc:dc>      
   </xsl:template>

</xsl:stylesheet> 
