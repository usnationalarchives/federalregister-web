<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!-- insert whitespace ahead of the node we are dealing with if needed -->
  <xsl:template name="optional_preceding_whitespace">
    <xsl:variable name="preceding_text" select="preceding-sibling::node()[1][self::text()]" />
    <xsl:if test="contains(');:,.abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', substring($preceding_text, string-length($preceding_text)))">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- insert whitespace after the node we are dealing with if needed -->
  <xsl:template name="optional_following_whitespace">
    <xsl:variable name="following_text" select="following-sibling::node()[1][self::text()]" />
    <xsl:choose>
      <xsl:when test="contains('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789(', substring($following_text,1,1))">
        <xsl:text> </xsl:text>
      </xsl:when>
      <!-- section symbol -->
      <xsl:when test="starts-with($following_text,'&#xA7;')">
        <xsl:text> </xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
