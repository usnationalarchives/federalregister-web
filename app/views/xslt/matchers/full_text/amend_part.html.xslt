<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fr="http://federalregister.gov/functions" extension-element-prefixes="fr">

  <xsl:template match="AMDPAR">
    <p class="amendment-part">
      <xsl:attribute name="id">
        <xsl:call-template name="amdpar_paragraph_id" />
      </xsl:attribute>

      <xsl:apply-templates select="fr:amendment_part(child::node())"/>
    </p>
  </xsl:template>

</xsl:stylesheet>
