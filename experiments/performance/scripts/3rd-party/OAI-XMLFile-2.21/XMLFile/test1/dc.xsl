<xsl:stylesheet version='1.0'
 xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
 xmlns:oaidc='http://www.openarchives.org/OAI/2.0/oai_dc/'
 xmlns:dc='http://purl.org/dc/elements/1.1/' 
 xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
>

<!-- 

   VRA Core v3 to PMH2 OAI_DC transformation
   Hussein Suleman
   16 October 2001
   v2.0: 29 june 2002
   Virginia Tech DLRL

-->


   <xsl:output method="xml"/>

   <xsl:template match="vra">
      <oaidc:dc xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
         <xsl:apply-templates select="record"/>
      </oaidc:dc>
   </xsl:template>
   
   <xsl:template match="record">
      <xsl:apply-templates select="title"/>
      <xsl:apply-templates select="creator"/>
      <xsl:apply-templates select="subject"/>
      <xsl:apply-templates select="description"/>
      <xsl:apply-templates select="date"/>
      <xsl:apply-templates select="recordtype"/>
      <dc:type>
         <xsl:value-of select="@type"/>
      </dc:type>
      <xsl:apply-templates select="type"/>
      <xsl:apply-templates select="measurements"/>
      <xsl:apply-templates select="material"/>
      <xsl:apply-templates select="technique"/>
      <xsl:apply-templates select="idnumber"/>
      <xsl:apply-templates select="source"/>
      <xsl:apply-templates select="relation"/>
      <xsl:apply-templates select="location"/>
      <xsl:apply-templates select="styleperiod"/>
      <xsl:apply-templates select="culture"/>
      <xsl:apply-templates select="rights"/>
   </xsl:template>
   
   <xsl:template match="recordtype">
      <dc:type>
         <xsl:value-of select="."/>
      </dc:type>
   </xsl:template>

   <xsl:template match="type">
      <dc:type>
         <xsl:value-of select="."/>
      </dc:type>
   </xsl:template>
   
   <xsl:template match="title">
      <dc:title>
         <xsl:value-of select="."/>
      </dc:title>
   </xsl:template>

   <xsl:template match="measurements">
      <dc:format>
         <xsl:value-of select="."/>
      </dc:format>
   </xsl:template>

   <xsl:template match="material">
      <dc:format>
         <xsl:value-of select="."/>
      </dc:format>
   </xsl:template>

   <xsl:template match="technique">
      <dc:format>
         <xsl:value-of select="."/>
      </dc:format>
   </xsl:template>

   <xsl:template match="creator">
      <dc:creator>
         <xsl:value-of select="."/>
      </dc:creator>
   </xsl:template>
   
   <xsl:template match="date">
      <dc:date>
         <xsl:value-of select="."/>
      </dc:date>
   </xsl:template>

   <xsl:template match="location">
      <dc:coverage>
         <xsl:value-of select="."/>
      </dc:coverage>
   </xsl:template>

   <xsl:template match="idnumber">
      <dc:identifier>
         <xsl:value-of select="."/>
      </dc:identifier>
   </xsl:template>

   <xsl:template match="styleperiod">
      <dc:coverage>
         <xsl:value-of select="."/>
      </dc:coverage>
   </xsl:template>

   <xsl:template match="culture">
      <dc:coverage>
         <xsl:value-of select="."/>
      </dc:coverage>
   </xsl:template>

   <xsl:template match="subject">
      <dc:subject>
         <xsl:value-of select="."/>
      </dc:subject>
   </xsl:template>

   <xsl:template match="relation">
      <dc:relation>
         <xsl:value-of select="."/>
      </dc:relation>
   </xsl:template>

   <xsl:template match="description">
      <dc:description>
         <xsl:value-of select="."/>
      </dc:description>
   </xsl:template>

   <xsl:template match="source">
      <dc:source>
         <xsl:value-of select="."/>
      </dc:source>
   </xsl:template>

   <xsl:template match="rights">
      <dc:rights>
         <xsl:value-of select="."/>
      </dc:rights>
   </xsl:template>

</xsl:stylesheet> 
