<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="SUPLINF">
    <span class="supplemental-info-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="supplemental-info unprinted-element cj-fancy-tooltip document-markup">
        <xsl:attribute name="data-tooltip-template">
          <xsl:value-of select="'#suplinf-tooltip-template'" />
        </xsl:attribute>

        <xsl:attribute name="data-tooltip-doc-override">
          <xsl:value-of select="'tooltip-enhanced'" />
        </xsl:attribute>

        <xsl:attribute name="data-text">
          <xsl:value-of select="'Start Supplemental Information'" />
        </xsl:attribute>

        <span class="icon-fr2 icon-fr2-source_code"></span>
        <span class="text">
          <xsl:text>Start Supplemental Information</xsl:text>
        </span>
      </span>
    </span>

    <xsl:apply-templates />

    <span class="supplemental-info-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="supplemental-info unprinted-element cj-fancy-tooltip document-markup">
        <xsl:attribute name="data-tooltip-template">
          <xsl:value-of select="'#suplinf-tooltip-template'" />
        </xsl:attribute>

        <xsl:attribute name="data-tooltip-doc-override">
          <xsl:value-of select="'tooltip-enhanced'" />
        </xsl:attribute>

        <xsl:attribute name="data-text">
          <xsl:value-of select="'End Supplemental Information'" />
        </xsl:attribute>

        <span class="icon-fr2 icon-fr2-source_code"></span>
        <span class="text">
          <xsl:text>End Supplemental Information</xsl:text>
        </span>
      </span>
    </span>
  </xsl:template>

</xsl:stylesheet>
