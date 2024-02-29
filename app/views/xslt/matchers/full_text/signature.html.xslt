<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="SIG">
    <div class="signature">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="DATED[ancestor::SIG]">
    <p class="signature-date">
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="NAME[ancestor::SIG]">
    <p class="signature-name">
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="TITLE[ancestor::SIG]">
    <p class="signature-title">
      <xsl:apply-templates />
    </p>
  </xsl:template>

</xsl:stylesheet>
