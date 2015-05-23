<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="SUPLINF">
    <span class="supplemental-info-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="supplemental-info unprinted-element icon-fr2 icon-fr2-doc-generic cj-tooltip">
        <xsl:attribute name="data-text">
          <xsl:value-of select="'Start Supplemental Information'" />
        </xsl:attribute>
        <xsl:text> </xsl:text>
      </span>
    </span>

    <xsl:apply-templates />

    <span class="supplemental-info-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="supplemental-info unprinted-element icon-fr2 icon-fr2-doc-generic cj-tooltip">
        <xsl:attribute name="data-text">
          <xsl:value-of select="'End Supplemental Information'" />
        </xsl:attribute>
        <xsl:text> </xsl:text>
      </span>
    </span>
  </xsl:template>

</xsl:stylesheet>

