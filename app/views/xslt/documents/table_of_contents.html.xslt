<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html" omit-xml-declaration="yes" />
  <xsl:include href="app/views/xslt/formatting.html.xslt" />
  <xsl:include href="app/views/xslt/headers.html.xslt" />

  <xsl:template name="table_of_contents" match="RULE | NOTICE">
    <xsl:choose>
      <xsl:when test="count(//HD[not(ancestor::NOTE|ancestor::FP)]) &gt; 0">
        <ul class="table-of-contents fr-list with-bullets">
          <xsl:apply-templates mode="table_of_contents"/>
        </ul>
      </xsl:when>
      <xsl:otherwise>
        <div>There is no table of contents available for this document.</div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="HD[@SOURCE='HED' or @SOURCE='HD1' or @SOURCE = 'HD2' or @SOURCE = 'HD3' or @SOURCE = 'HD4'][not(ancestor::NOTE|ancestor::FP|ancestor::AUTH)]" mode="table_of_contents">
    <xsl:choose>
      <xsl:when test="text() = 'AGENCY:' or text() = 'ACTION:' or text() = 'SUMMARY:'"/>
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

  <xsl:template mode="table_of_contents" match="*[name(.) != 'HD']|text()">
    <xsl:apply-templates mode="table_of_contents"/>
  </xsl:template>
</xsl:stylesheet>
