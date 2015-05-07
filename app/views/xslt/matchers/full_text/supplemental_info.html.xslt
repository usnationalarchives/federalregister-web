<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="SUPLINF">
    <span class="unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="supplemental-info unprinted-element icon-fr2 icon-fr2-doc-generic cj-tooltip">
        <xsl:attribute name="data-tooltip">
          <xsl:value-of select="'Start Supplemental Information'" />
        </xsl:attribute>
        <xsl:text> </xsl:text>
      </span>
      <span class="unprinted-element-border"></span>
    </span>

    <xsl:apply-templates />

    <span class="unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="supplemental-info unprinted-element icon-fr2 icon-fr2-doc-generic cj-tooltip">
        <xsl:attribute name="data-tooltip">
          <xsl:value-of select="'End Supplemental Information'" />
        </xsl:attribute>
        <xsl:text> </xsl:text>
      </span>
      <span class="unprinted-element-border"></span>
    </span>
  </xsl:template>

</xsl:stylesheet>

