<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:saxon="http://saxon.sf.net/"
	exclude-result-prefixes="xs"
	version="2.0">
    
    <!-- DON'T FORGET TO SET XSLT TRANSFORMER TO IGNORE THE SCHEMA (TO AVOID ADDING DEFAULT ATTRIBUTES) -->

	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:variable name="newline" select="'&#10;'"/>
    
	<xsl:variable name="works" select="document('../../authority/works_master.xml')//tei:TEI/tei:text/tei:body/tei:listBibl/tei:bibl"/>
	<xsl:variable name="people" select="document('../../authority/persons_master.xml')//tei:TEI/tei:text/tei:body/tei:listPerson/tei:person"/>
	<xsl:variable name="places" select="document('../../authority/places_master.xml')//tei:TEI/tei:text/tei:body/tei:listPlace/tei:place"/>
	
	<xsl:template match="/">
		<xsl:value-of select="$newline"/>
		<xsl:processing-instruction name="xml-model"><xsl:text>href="https://raw.githubusercontent.com/bodleian/consolidated-tei-schema/master/msdesc.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text></xsl:processing-instruction><xsl:value-of select="$newline"/>
		<xsl:processing-instruction name="xml-model"><xsl:text>href="https://raw.githubusercontent.com/bodleian/consolidated-tei-schema/master/msdesc.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:text></xsl:processing-instruction><xsl:value-of select="$newline"/>
		<xsl:apply-templates select="*[not(processing-instruction('xml-model'))]"/>
	</xsl:template>

	<xsl:template match="*">
		<xsl:copy>
			<xsl:apply-templates select="@*[not(name()='key')]"/>    <!-- A very, very few already have keys, and they don't relate to anything, so strip them out. -->
		    <xsl:choose>
                <!-- Don't do msItems
		        <xsl:when test="self::tei:msItem">
		            <xsl:variable name="thisid" select="@xml:id"/>
		            <xsl:if test="$thisid = $works/tei:ref/@target">
		                <xsl:attribute name="key" select="$works[tei:ref/@target = $thisid]/@xml:id"/>
		            </xsl:if>
		        </xsl:when>-->
                <xsl:when test="self::tei:author">
		            <xsl:variable name="thisval" select="normalize-space(string-join(.//text(), ' '))"/>
		            <xsl:if test="$thisval = $people/tei:persName">
		                <xsl:attribute name="key" select="$people[tei:persName = $thisval]/@xml:id"/>
		            </xsl:if>
		        </xsl:when>
		        <xsl:when test="self::tei:persName">
		            <xsl:variable name="thisval" select="normalize-space(string-join(.//text(), ' '))"/>
		            <xsl:if test="$thisval = $people/tei:persName">
		                <xsl:attribute name="key" select="$people[tei:persName = $thisval]/@xml:id"/>
		            </xsl:if>
		        </xsl:when>
		        <xsl:when test="self::tei:placeName">
		            <xsl:variable name="thisval" select="normalize-space(string-join(.//text(), ' '))"/>
		            <xsl:if test="$thisval = $places/tei:placeName">
		                <xsl:attribute name="key" select="$places[tei:placeName = $thisval]/@xml:id"/>
		            </xsl:if>
		        </xsl:when>
		    </xsl:choose>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
    	
	<xsl:template match="@*|comment()|processing-instruction()">
		<xsl:copy/>
	</xsl:template>

</xsl:stylesheet>