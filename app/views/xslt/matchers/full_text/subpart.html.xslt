<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fr="http://federalregister.gov/functions" extension-element-prefixes="fr">

  <xsl:template match="SUBPART">
    <span class="subpart-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="subpart unprinted-element icon-fr2 icon-fr2-book cj-tooltip">
        <xsl:attribute name="data-tooltip">
          <xsl:value-of select="'Start Sub-Part'" />
        </xsl:attribute>
        <xsl:text> </xsl:text>
      </span>
      <span class="unprinted-element-border"></span>
    </span>

    <xsl:apply-templates />

    <span class="subpart-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="subpart unprinted-element icon-fr2 icon-fr2-book cj-tooltip">
        <xsl:attribute name="data-tooltip">
          <xsl:value-of select="'End Sub-Part'" />
        </xsl:attribute>
        <xsl:text> </xsl:text>
      </span>
      <span class="unprinted-element-border"></span>
    </span>
  </xsl:template>
</xsl:stylesheet>
