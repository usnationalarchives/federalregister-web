<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <!--
    text italicised in header
    See page 9 here: http://www.gpo.gov/fdsys/pkg/FR-2015-01-22/pdf/2015-00344.pdf
  -->
  <xsl:template match="E[@T=7462]">
    <em>
      <xsl:apply-templates />
    </em>
  </xsl:template>

  <xsl:template match="E[@T=04]">
    <strong>
      <xsl:apply-templates />
    </strong>
  </xsl:template>

</xsl:stylesheet>
