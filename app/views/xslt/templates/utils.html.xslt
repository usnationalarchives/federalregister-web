<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <!--  used to replace text in a string as XSLT 1.0 doesn't have a
        replace function.
        Usage:
        <xsl:variable name="newtext">
          <xsl:call-template name="string-replace-all">
            <xsl:with-param name="text" select="$text" />
            <xsl:with-param name="replace" select="a" />
            <xsl:with-param name="by" select="b" />
          </xsl:call-template>
        </xsl:variable>
      -->
  <xsl:template name="string_replace_all">
    <xsl:param name="text" />
    <xsl:param name="replace" />
    <xsl:param name="by" />
    <xsl:choose>
      <xsl:when test="contains($text, $replace)">
        <xsl:value-of select="substring-before($text,$replace)" />
        <xsl:value-of select="$by" />
        <xsl:call-template name="string_replace_all">
          <xsl:with-param name="text"
          select="substring-after($text,$replace)" />
          <xsl:with-param name="replace" select="$replace" />
          <xsl:with-param name="by" select="$by" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
