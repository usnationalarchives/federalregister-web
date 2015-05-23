<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!--  Due to the way the the PDF's are printed (footnotes start at the
        bottom of the page in which they are first referenced) footnotes
        can also be broken across pages. The PRTPAGE elements in footnotes
        don't have a page number associated. See 2014-27286 footnote 1 for
        an example.

        We collect all footnotes at the bottom of the document and link them,
        so we just ignore the PRTPAGE found in footnotes here. -->
  <xsl:template match="PRTPAGE[not(ancestor::FTNT)]">
    <span class="printed-page-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="printed-page unprinted-element icon-fr2 icon-fr2-doc-generic cj-tooltip">
        <xsl:attribute name="id">
          <xsl:text>page-</xsl:text><xsl:value-of select="@P" />
        </xsl:attribute>
        <xsl:attribute name="data-page">
          <xsl:value-of select="@P" />
        </xsl:attribute>
        <xsl:attribute name="data-text">
          <xsl:value-of select="concat('Start Printed Page ', @P)" />
        </xsl:attribute>
        <xsl:text> </xsl:text>
      </span>
    </span>
  </xsl:template>
</xsl:stylesheet>
