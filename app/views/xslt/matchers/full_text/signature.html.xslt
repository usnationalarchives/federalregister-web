<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="SIG">
    <span class="signature-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="signature unprinted-element icon-fr2 icon-fr2-pen cj-tooltip">
        <xsl:attribute name="data-tooltip">
          <xsl:value-of select="'Start Signature'" />
        </xsl:attribute>
        <xsl:text> </xsl:text>
      </span>
      <span class="unprinted-element-border"></span>
    </span>

    <div class="signature">
      <xsl:apply-templates />
    </div>

    <span class="signature-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="signature unprinted-element icon-fr2 icon-fr2-pen cj-tooltip">
        <xsl:attribute name="data-tooltip">
          <xsl:value-of select="'End Signature'" />
        </xsl:attribute>
        <xsl:text> </xsl:text>
      </span>
      <span class="unprinted-element-border"></span>
    </span>
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
