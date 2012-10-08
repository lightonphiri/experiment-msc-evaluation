<xsl:stylesheet version='1.0'
 xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
 xmlns:vra='http://www.gsd.harvard.edu/~staffaw3/vra/vracore3.htm'
 xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
 
>

<!-- 

   VRA Core v3 to VRA Core v3 w/namespaces transformation
   Hussein Suleman
   29 june 2002
   Virginia Tech DLRL

-->


   <xsl:output method="xml"/>

   <xsl:template match="vra">
      <vra:vracore xsi:schemaLocation="http://www.gsd.harvard.edu/~staffaw3/vra/vracore3.htm http://oai.dlib.vt.edu/OAI/1.1/oai_vracore.xsd">
         <xsl:apply-templates select="record"/>
      </vra:vracore>
   </xsl:template>
   
   <xsl:template match="record">
      <vra:record vra:type="{@type}">
         <xsl:for-each select="type"><vra:type><xsl:value-of select="."/></vra:type></xsl:for-each>
         
         <xsl:for-each select="title">
            <xsl:choose>
               <xsl:when test="@type">
                  <vra:title vra:type="{@type}"><xsl:value-of select="."/></vra:title>
               </xsl:when>
               <xsl:otherwise>
                  <vra:title><xsl:value-of select="."/></vra:title>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:for-each>
         
         <xsl:for-each select="measurements">
            <xsl:choose>
               <xsl:when test="@type">
                  <vra:measurements vra:type="{@type}"><xsl:value-of select="."/></vra:measurements>
               </xsl:when>
               <xsl:otherwise>
                  <vra:measurements><xsl:value-of select="."/></vra:measurements>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:for-each>

         <xsl:for-each select="material">
            <xsl:choose>
               <xsl:when test="@type">
                  <vra:material vra:type="{@type}"><xsl:value-of select="."/></vra:material>
               </xsl:when>
               <xsl:otherwise>
                  <vra:material><xsl:value-of select="."/></vra:material>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:for-each>
         
         <xsl:for-each select="technique"><vra:technique><xsl:value-of select="."/></vra:technique></xsl:for-each>

         <xsl:for-each select="creator">
            <xsl:choose>
               <xsl:when test="@type and @role">
                  <vra:creator vra:type="{@type}" vra:role="{@role}"><xsl:value-of select="."/></vra:creator>
               </xsl:when>
               <xsl:when test="@type">
                  <vra:creator vra:type="{@type}"><xsl:value-of select="."/></vra:creator>
               </xsl:when>
               <xsl:when test="@role">
                  <vra:creator vra:role="{@role}"><xsl:value-of select="."/></vra:creator>
               </xsl:when>
               <xsl:otherwise>
                  <vra:creator><xsl:value-of select="."/></vra:creator>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:for-each>

         <xsl:for-each select="date">
            <xsl:choose>
               <xsl:when test="@type">
                  <vra:date vra:type="{@type}"><xsl:value-of select="."/></vra:date>
               </xsl:when>
               <xsl:otherwise>
                  <vra:date><xsl:value-of select="."/></vra:date>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:for-each>

         <xsl:for-each select="location">
            <xsl:choose>
               <xsl:when test="@type">
                  <vra:location vra:type="{@type}"><xsl:value-of select="."/></vra:location>
               </xsl:when>
               <xsl:otherwise>
                  <vra:location><xsl:value-of select="."/></vra:location>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:for-each>

         <xsl:for-each select="idnumber">
            <xsl:choose>
               <xsl:when test="@type">
                  <vra:idnumber vra:type="{@type}"><xsl:value-of select="."/></vra:idnumber>
               </xsl:when>
               <xsl:otherwise>
                  <vra:idnumber><xsl:value-of select="."/></vra:idnumber>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:for-each>

         <xsl:for-each select="styleperiod">
            <xsl:choose>
               <xsl:when test="@type">
                  <vra:styleperiod vra:type="{@type}"><xsl:value-of select="."/></vra:styleperiod>
               </xsl:when>
               <xsl:otherwise>
                  <vra:styleperiod><xsl:value-of select="."/></vra:styleperiod>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:for-each>

         <xsl:for-each select="culture"><vra:culture><xsl:value-of select="."/></vra:culture></xsl:for-each>

         <xsl:for-each select="subject"><vra:subject><xsl:value-of select="."/></vra:subject></xsl:for-each>

         <xsl:for-each select="relation">
            <xsl:choose>
               <xsl:when test="@type">
                  <vra:relation vra:type="{@type}"><xsl:value-of select="."/></vra:relation>
               </xsl:when>
               <xsl:otherwise>
                  <vra:relation><xsl:value-of select="."/></vra:relation>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:for-each>

         <xsl:for-each select="description"><vra:description><xsl:value-of select="."/></vra:description></xsl:for-each>

         <xsl:for-each select="source"><vra:source><xsl:value-of select="."/></vra:source></xsl:for-each>

         <xsl:for-each select="rights"><vra:rights><xsl:value-of select="."/></vra:rights></xsl:for-each>

      </vra:record>
   </xsl:template>

</xsl:stylesheet> 
