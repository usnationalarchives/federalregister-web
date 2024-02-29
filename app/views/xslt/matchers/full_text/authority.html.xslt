<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fr="http://federalregister.gov/functions" extension-element-prefixes="fr">

  <xsl:template match="AUTH">
    <p class="authority">
      <xsl:attribute name="id">
        <xsl:call-template name="paragraph_id" />
      </xsl:attribute>

      <xsl:attribute name="data-page">
        <xsl:call-template name="printed_page" />
      </xsl:attribute>

      <xsl:apply-templates />
    </p>
  </xsl:template>
</xsl:stylesheet>
