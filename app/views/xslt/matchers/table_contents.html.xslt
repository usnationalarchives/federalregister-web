<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:include href="app/views/xslt/matchers/text/all.html.xslt" />
  <xsl:template match="LI">
    <!-- add a space before and after -->
    <xsl:value-of select="' '" />
    <xsl:apply-templates />
    <xsl:value-of select="' '" />
  </xsl:template>
</xsl:stylesheet>
