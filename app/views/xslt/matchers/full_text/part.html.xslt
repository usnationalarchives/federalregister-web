<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fr="http://federalregister.gov/functions" extension-element-prefixes="fr">

  <xsl:template match="PART">
    <div class="part">
      <xsl:apply-templates />
    </div>
  </xsl:template>
</xsl:stylesheet>
