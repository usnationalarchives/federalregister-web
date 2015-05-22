<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html" omit-xml-declaration="yes" />

  <xsl:include href="app/views/xslt/templates/headers.html.xslt" />
  <xsl:include href="app/views/xslt/templates/utils.html.xslt" />

  <xsl:include href="app/views/xslt/matchers/text/all.html.xslt" />


  <!-- ignore all the text modes until we process them later without a 'mode' -->
  <xsl:template mode="table_of_contents" match="text()|@*" />

  <xsl:template name="table_of_contents" match="/">
    <xsl:choose>
      <xsl:when test="count(//HD[not(ancestor::NOTE|ancestor::FP)]) &gt; 0">
        <ul class="table-of-contents fr-list with-bullets">
          <xsl:apply-templates mode="table_of_contents"/>
          <xsl:call-template name="footnotes" mode="table_of_contents" />
        </ul>
      </xsl:when>
      <xsl:otherwise>
        <div>There is no table of contents available for this document.</div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="HD[@SOURCE='HED' or @SOURCE='HD1' or @SOURCE = 'HD2' or @SOURCE = 'HD3' or @SOURCE = 'HD4'][not(ancestor::NOTE|ancestor::FP|ancestor::AUTH)]" mode="table_of_contents">
    <xsl:choose>
      <xsl:when test="text() = 'AGENCY:'"/>
      <xsl:otherwise>
        <li>
          <xsl:attribute name="class">
            <xsl:text>level-</xsl:text>
            <xsl:call-template name="header_level">
              <xsl:with-param name="source" select="@SOURCE"/>
            </xsl:call-template>
          </xsl:attribute>
          <a>
            <xsl:attribute name="href">
              <xsl:text>#</xsl:text>
              <xsl:call-template name="header_id" />
            </xsl:attribute>
            <xsl:apply-templates/>
          </a>
        </li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="LSTSUB/CFR" mode="table_of_contents">
    <xsl:variable name="id">
      <xsl:call-template name="string_replace_all">
        <xsl:with-param name="text" select="text()" />
        <xsl:with-param name="replace" select="' '" />
        <xsl:with-param name="by" select="'-'" />
      </xsl:call-template>
    </xsl:variable>

    <li>
      <xsl:attribute name="class">
        <xsl:text>level-</xsl:text>
        <xsl:call-template name="header_level">
          <xsl:with-param name="source" select="1"/>
        </xsl:call-template>
      </xsl:attribute>
      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="concat('#los-', $id)" />
        </xsl:attribute>
        <xsl:apply-templates/>
      </a>
    </li>
  </xsl:template>

  <xsl:template match="//FTNT[0]" name="footnotes" mode="table_of_contents">
    <xsl:if test="count(//FTNT) &gt; 0">
      <li>
        <xsl:attribute name="class">
          <xsl:text>level-</xsl:text>
          <xsl:call-template name="header_level">
            <xsl:with-param name="source" select="0"/>
          </xsl:call-template>
        </xsl:attribute>
        <a>
          <xsl:attribute name="href">
            <xsl:value-of select="'#footnotes'" />
          </xsl:attribute>

          <xsl:text>Footnotes</xsl:text>
        </a>
      </li>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
