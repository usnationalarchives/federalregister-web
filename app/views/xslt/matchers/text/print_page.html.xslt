<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fr="http://federalregister.gov/functions" extension-element-prefixes="fr">

  <!--  Due to the way the the PDF's are printed (footnotes start at the
        bottom of the page in which they are first referenced) footnotes
        can also be broken across pages. The PRTPAGE elements in footnotes
        don't have a page number associated. See 2014-27286 footnote 1 for
        an example.

        We collect all footnotes at the bottom of the document and link them,
        so we just ignore the PRTPAGE found in footnotes here. -->
  <xsl:template match="PRTPAGE[not(ancestor::FTNT)]">
    <span class="printed-page-inline unprinted-element document-markup">
      <xsl:attribute name="data-page">
        <xsl:value-of select="@P" />
      </xsl:attribute>

      <xsl:copy-of select="fr:svg_icon('doc-generic')" />
    </span>

    <span class="printed-page-details unprinted-element document-markup cj-tooltip">
      <xsl:attribute name="id">
        <xsl:text>page-</xsl:text><xsl:value-of select="@P" />
      </xsl:attribute>

      <xsl:attribute name="data-page">
        <xsl:value-of select="@P" />
      </xsl:attribute>

      <xsl:attribute name="data-text">
        <xsl:value-of select="concat('Print Page ', @P)" />
      </xsl:attribute>

      <xsl:attribute name="data-tooltip-template">
        <xsl:value-of select="'#print-page-tooltip-template'" />
      </xsl:attribute>

      <xsl:attribute name="data-toggle">
        <xsl:value-of select="'popover'" />
      </xsl:attribute>

      <xsl:attribute name="data-original-title">
        <xsl:value-of select="''" />
      </xsl:attribute>

      <xsl:attribute name="data-placement">
        <xsl:value-of select="'left'" />
      </xsl:attribute>

      <xsl:attribute name="data-html">
        <xsl:value-of select="'true'" />
      </xsl:attribute>

      <xsl:attribute name="data-tooltip-data">
        <xsl:text>{"page": </xsl:text>
        <xsl:value-of select="@P" />
        <xsl:text>}</xsl:text>
      </xsl:attribute>

      <xsl:attribute name="data-tooltip">
        <xsl:value-of select="'Click for more print page information'" />
      </xsl:attribute>

      <xsl:copy-of select="fr:svg_icon('doc-generic')" />

      <span class="text">
        <xsl:text>Print Page </xsl:text>
        <xsl:value-of select="@P" />
      </span>
    </span>
  </xsl:template>
</xsl:stylesheet>
