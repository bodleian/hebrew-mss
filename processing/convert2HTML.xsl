<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:bod="http://www.bodleian.ox.ac.uk/bdlss"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei html xs bod"
    version="2.0">
    
    <xsl:import href="https://raw.githubusercontent.com/bodleian/consolidated-tei-schema/master/msdesc2html.xsl"/> 

    <!-- Only set this variable if you want full URLs hardcoded into the HTML
         on the web site (previewManuscript.xsl overrides this to do so when previewing.) -->
    <xsl:variable name="website-url" as="xs:string" select="''"/>

    <!-- Any templates added below will override the templates in the shared
         imported stylesheet, allowing customization of manuscript display for each catalogue. -->

    <xsl:template name="Header">
        <aside class="aside-navigation ">
            <p>List of works:</p>
            <table role="nav">
                <xsl:apply-templates select="/TEI/teiHeader/fileDesc/sourceDesc/msDesc//msItem[title]" mode="fraglist"/>
                <xsl:if test="count(/TEI/teiHeader/fileDesc/sourceDesc/msDesc//msItem[title]) eq 0">
                    <tr><td colspan="2"><xsl:text>No works have been identified in this manuscript.</xsl:text></td></tr>
                </xsl:if>
            </table>
        </aside>
    </xsl:template>
    
    <xsl:template match="msItem" mode="fraglist">
        <tr>
            <td>
                <xsl:variable name="titletext" select="normalize-space(string-join(title[1]//text()[not(ancestor::foreign)], ' '))"/>
                <a href="{ concat('#', @xml:id) }" title="{ $titletext }">
                    <xsl:value-of select="bod:shortenToNearestWord($titletext, 48)"/>
                </a>
            </td>
            <td>
                <xsl:if test="ancestor::msPart or .//locus">
                    <xsl:if test="ancestor::msPart and (ancestor::msPart//msItem[title])[1]/@xml:id = @xml:id">
                        <a href="{ concat('#', ancestor::msPart[1]/@xml:id) }">
                            <xsl:text>Part </xsl:text>
                            <xsl:value-of select="ancestor::msPart[1]/@n"/>
                        </a>
                        <xsl:if test=".//locus">
                            <br/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:apply-templates select="(.//locus)[1]" mode="fraglist"/>
                </xsl:if>
            </td>
        </tr>
    </xsl:template>
    
    <xsl:template match="locus" mode="fraglist">
        <xsl:choose>
            <xsl:when test="exists(.//text())">
                <xsl:value-of select="normalize-space(string-join(.//text(), ' '))"/>
            </xsl:when>
            <xsl:when test="@from and @to">
                <xsl:text>fols. </xsl:text>
                <xsl:value-of select="@from"/>
                <xsl:text>–</xsl:text>
                <xsl:value-of select="@to"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    
   
    <xsl:template name="AdditionalContent">
        <xsl:if test="starts-with(/TEI/@xml:id, 'volume_')">
            <!-- Currently only Genizah has images -->
            <div class="additional_content">
                <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/msDesc/additional/adminInfo/tei:recordHist/tei:source/tei:ref/@facs">
                    <h3>Catalogue Images</h3>
                    <ul style="list-style-type:none;">
                        <xsl:for-each select="tokenize(normalize-space(string-join(/TEI/teiHeader/fileDesc/sourceDesc/msDesc/additional/adminInfo/tei:recordHist/tei:source/tei:ref/@facs, ' ')), ' ')">
                            <li>
                                <a href="{ concat('/images/catalogue/', .) }"><xsl:value-of select="substring-before(substring-after(., '_'), '.jpg')"/></a>
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                <xsl:if test="/TEI/facsimile/graphic">
                    <h3>Fragment Images</h3>
                    <p style="float:right;">
                        <xsl:for-each select="/TEI/facsimile/graphic/@url">
                            <xsl:variable name="jpgfilename" select="replace(., '\.tiff*$', '.jpg')"/>
                            <xsl:variable name="fullsizefile" select="concat('/fragments/full/', $jpgfilename)"/>
                            <xsl:variable name="thumbfile" select="concat('/fragments/thumbs/', $jpgfilename)"/>
                            <xsl:variable name="folio" select="tokenize(substring-before($jpgfilename, '.jpg'), '_')[last()]"/>
                            <a href="{ $fullsizefile }" title="{ $folio }" style="display: inline-block; float:right;">
                                <img src="{ $thumbfile }" alt="Thumbnail of { $folio }" height="80"/>
                            </a>
                        </xsl:for-each>
                    </p>
                </xsl:if>
            </div>
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>
