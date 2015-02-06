<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!-- return the printed page number for the current node -->
  <xsl:template name="current_page">
    <xsl:variable name="current_page">
      <xsl:value-of select="preceding::PRTPAGE[not(ancestor::FTNT)][1]/@P" />
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="number($current_page)">
        <xsl:value-of select="$current_page" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$first_page" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
