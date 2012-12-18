<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:oaidc='http://www.openarchives.org/OAI/2.0/oai_dc/'
	xmlns:oai_dc='http://www.openarchives.org/OAI/2.0/oai_dc/'
	xmlns:dc='http://purl.org/dc/elements/1.1/'
	xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>

	<xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/">
		<add><xsl:apply-templates select="record" /></add>
	</xsl:template>
	<xsl:template match="record">
		<doc>
			<!--field column="dc-identifier" xpath="/record/header/identifier" commonField="true" /-->
			<field name="id"><xsl:value-of select="header/identifier" /></field>
			<!--field column="dc-available" xpath="/record/header/datestamp" commonField="true" /-->
			<field name="available"><xsl:value-of select="header/datestamp" /></field>
			<!--field column="dc-publisher" xpath="/record/header/setSpec" commonField="true" /-->
			<field name="source"><xsl:value-of select="header/setSpec" /></field>
			<xsl:apply-templates select="//metadata/oai_dc:dc/dc:title" />
			<xsl:apply-templates select="//metadata/oai_dc:dc/dc:publisher" />
			<xsl:apply-templates select="//metadata/oai_dc:dc/dc:creator" />
			<xsl:apply-templates select="//metadata/oai_dc:dc/dc:subject" />
			<xsl:apply-templates select="//metadata/oai_dc:dc/dc:description" />
			<xsl:apply-templates select="//metadata/oai_dc:dc/dc:contributor" />
			<xsl:apply-templates select="//metadata/oai_dc:dc/dc:date" />
			<xsl:apply-templates select="//metadata/oai_dc:dc/dc:type" />
			<xsl:apply-templates select="//metadata/oai_dc:dc/dc:format" />
			<xsl:apply-templates select="//metadata/oai_dc:dc/dc:language" />
			<xsl:apply-templates select="//metadata/oai_dc:dc/dc:relation" />
			<xsl:apply-templates select="//metadata/oai_dc:dc/dc:coverage" />
			<xsl:apply-templates select="//metadata/oai_dc:dc/dc:rights" />
		</doc>
	</xsl:template>
	<!--field column="dc-title" xpath="/record/metadata/dc/title" /-->
	<xsl:template match="dc:title">
		<field name="title"><xsl:value-of select="." /></field>
	</xsl:template>
	<!--field column="dc-publisher" xpath="/record/header/setSpec" commonField="true" /-->
	<xsl:template match="dc:publisher">
		<field name="publisher"><xsl:value-of select="." /></field>
	</xsl:template>
	<!--field column="dc-creator" xpath="/record/metadata/dc/creator" /-->
	<xsl:template match="dc:creator">
		<field name="creator"><xsl:value-of select="." /></field>
	</xsl:template>
	<!--field column="dc-subject" xpath="/record/metadata/dc/subject" /-->
	<xsl:template match="dc:subject">
		<field name="subject"><xsl:value-of select="." /></field>
	</xsl:template>
	<!--field column="dc-description" xpath="/record/metadata/dc/description" /-->
	<xsl:template match="dc:description">
		<field name="description"><xsl:value-of select="." /></field>
	</xsl:template>
	<!--field column="dc-publisher" xpath="/record/metadata/dc/publisher" /-->
	<xsl:template match="dc:publisher">
		<field name="publisher"><xsl:value-of select="." /></field>
	</xsl:template>
	<!--field column="dc-contributor" xpath="/record/metadata/dc/contributor" /-->
	<xsl:template match="dc:contributor">
		<field name="contributor"><xsl:value-of select="." /></field>
	</xsl:template>
	<!--field column="dc-date" xpath="/record/metadata/dc/date" /-->
	<xsl:template match="dc:date">
		<field name="date"><xsl:value-of select="." /></field>
	</xsl:template>
	<!--field column="dc-type" xpath="/record/metadata/dc/type" /-->
	<xsl:template match="dc:type">
		<field name="type"><xsl:value-of select="." /></field>
	</xsl:template>
	<!--field column="dc-format" xpath="/record/metadata/dc/format" /-->
	<xsl:template match="dc:format">
		<field name="format"><xsl:value-of select="." /></field>
	</xsl:template>
	<!--field column="dc-language" xpath="/record/metadata/dc/language" /-->
	<xsl:template match="dc:language">
		<field name="language"><xsl:value-of select="." /></field>
	</xsl:template>
	<!--field column="dc-relation" xpath="/record/metadata/dc/relation" /-->
	<xsl:template match="dc:relation">
		<field name="relation"><xsl:value-of select="." /></field>
	</xsl:template>
	<!--field column="dc-coverage" xpath="/record/metadata/dc/coverage" /-->
	<xsl:template match="dc:coverage">
		<field name="coverage"><xsl:value select="." /></field>
	</xsl:template>
	<!--field column="dc-rights" xpath="/record/metadata/dc/rights" /-->
	<xsl:template match="dc:rights">
		<field name="rights"><xsl:value select="." /></field>
	</xsl:template>
</xsl:stylesheet>
