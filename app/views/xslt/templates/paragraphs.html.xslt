<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!--  generate a paragraph id based on the number of preceeding P or FP tags
        in the XML -->
  <xsl:template name="paragraph_id">
    <xsl:value-of select="concat('p-', count(preceding::*[name(.) = 'P' or name(.) = 'FP'])+1)" />
  </xsl:template>

  <!--  generate a paragraph id based on the number of preceeding AMDPAR tags
        in the XML -->
  <xsl:template name="amdpar_paragraph_id">
    <xsl:value-of select="concat('p-amd-', count(preceding::*[name(.) = 'AMDPAR'])+1)" />
  </xsl:template>
</xsl:stylesheet>
