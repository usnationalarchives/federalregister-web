<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:include href="../../templates/headers.html.xslt" />

  <xsl:template match="HD[@SOURCE='HED' or @SOURCE='HD1' or @SOURCE = 'HD2' or @SOURCE = 'HD3' or @SOURCE = 'HD4']">
    <xsl:call-template name="header" />
  </xsl:template>

  <xsl:template match="HD[@SOURCE='HED' and ancestor::AUTH]">
    <span class="auth-header">
      <xsl:apply-templates />
    </span>
  </xsl:template>

</xsl:stylesheet>
