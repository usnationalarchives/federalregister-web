<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template mode="footnotes" match="FTNT">
    <xsl:variable name="number">
      <xsl:value-of select="descendant::SU/text()"/>
    </xsl:variable>

    <div class="footnote">
      <xsl:attribute name="id">
        <xsl:value-of select="concat('footnote-', $number)"/>
      </xsl:attribute>

      <xsl:apply-templates />

      <a class="back">
        <xsl:attribute name="href">
          #citation-<xsl:value-of select="$number"/>
        </xsl:attribute>
        Back to Context
      </a>
    </div>
  </xsl:template>

  <xsl:template match="SU[following-sibling::FTREF]">
    <xsl:variable name="number">
      <xsl:value-of select="text()"/>
    </xsl:variable>

    <sup>
      <xsl:attribute name="id">
        <xsl:value-of select="concat('citation-', $number)"/>
      </xsl:attribute>

      [<a class="footnote-reference">
        <xsl:attribute name="href">
          #footnote-<xsl:value-of select="$number"/>
        </xsl:attribute>

        <xsl:apply-templates />
      </a>]
    </sup>
  </xsl:template>

  <xsl:template match="SU[ancestor::FTNT]">
    <xsl:apply-templates />.
    <xsl:call-template name="optional_following_whitespace" />
  </xsl:template>

  <xsl:template name="footnotes">
    <xsl:if test="count(//FTNT) &gt; 0">
      <xsl:call-template name="manual_header">
        <xsl:with-param name="id" select="'footnotes'"/>
        <xsl:with-param name="name" select="'Footnotes'"/>
        <xsl:with-param name="level" select="1"/>
      </xsl:call-template>
      <div class="footnotes">
        <xsl:apply-templates select="//FTNT" mode="footnotes"/>
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
