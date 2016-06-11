<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="SIG">
    <span class="signature-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="signature unprinted-element cj-fancy-tooltip document-markup">
        <xsl:attribute name="data-tooltip-template">
          <xsl:value-of select="'#signature-tooltip-template'" />
        </xsl:attribute>

        <xsl:attribute name="data-tooltip-doc-override">
          <xsl:value-of select="'tooltip-enhanced'" />
        </xsl:attribute>

        <xsl:attribute name="data-text">
          <xsl:value-of select="'Start Signature'" />
        </xsl:attribute>

        <span class="icon-fr2 icon-fr2-source_code"></span>
        <span class="text">
          <xsl:text>Start Signature</xsl:text>
        </span>
      </span>
      <span class="unprinted-element-border"></span>
    </span>

    <div class="signature">
      <xsl:apply-templates />
    </div>
    
    <span class="signature-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="signature unprinted-element cj-fancy-tooltip document-markup">
        <xsl:attribute name="data-tooltip-template">
          <xsl:value-of select="'#signature-tooltip-template'" />
        </xsl:attribute>

        <xsl:attribute name="data-tooltip-doc-override">
          <xsl:value-of select="'tooltip-enhanced'" />
        </xsl:attribute>

        <xsl:attribute name="data-text">
          <xsl:value-of select="'End Signature'" />
        </xsl:attribute>

        <span class="icon-fr2 icon-fr2-source_code"></span>
        <span class="text">
          <xsl:text>End Signature</xsl:text>
        </span>
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
