<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!--  These are elements that are marked up by OFR/GPO and
        delineate particular sections of the document, but are
        not printed. We offer these as an enhancement to aid the
        user in understanding the document. -->

  <!-- SIG nodes are handled in the signature matcher -->

  <xsl:template match="PREAMB">
    <span class="preamble-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="preamble unprinted-element icon-fr2 icon-fr2-doc-generic cj-fancy-tooltip document-markup">
        <xsl:attribute name="data-tooltip-template">
          <xsl:value-of select="'#preamble-tooltip-template'" />
        </xsl:attribute>

        <xsl:attribute name="data-tooltip-doc-override">
          <xsl:value-of select="'tooltip-enhanced'" />
        </xsl:attribute>

        <xsl:attribute name="data-text">
          <xsl:value-of select="'Start Preamble'" />
        </xsl:attribute>

        <xsl:text> </xsl:text>
      </span>
    </span>

    <xsl:apply-templates />

    <span class="preamble-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="preamble unprinted-element icon-fr2 icon-fr2-doc-generic cj-fancy-tooltip document-markup">
        <xsl:attribute name="data-tooltip-template">
          <xsl:value-of select="'#preamble-tooltip-template'" />
        </xsl:attribute>

        <xsl:attribute name="data-tooltip-doc-override">
          <xsl:value-of select="'tooltip-enhanced'" />
        </xsl:attribute>

        <xsl:attribute name="data-text">
          <xsl:value-of select="'End Preamble'" />
        </xsl:attribute>

        <xsl:text> </xsl:text>
      </span>
    </span>
  </xsl:template>

  <xsl:template match="APPENDIX">
    <span class="appendix-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="appendix unprinted-element icon-fr2 icon-fr2-doc-generic cj-fancy-tooltip document-markup">
        <xsl:attribute name="data-tooltip-template">
          <xsl:value-of select="'#appendix-tooltip-template'" />
        </xsl:attribute>

        <xsl:attribute name="data-tooltip-doc-override">
          <xsl:value-of select="'tooltip-enhanced'" />
        </xsl:attribute>

        <xsl:attribute name="data-text">
          <xsl:value-of select="'Start Appendix'" />
        </xsl:attribute>
        <xsl:text> </xsl:text>
      </span>
    </span>

    <xsl:apply-templates />

    <span class="appendix-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="appendix unprinted-element icon-fr2 icon-fr2-doc-generic cj-fancy-tooltip document-markup">
        <xsl:attribute name="data-tooltip-template">
          <xsl:value-of select="'#appendix-tooltip-template'" />
        </xsl:attribute>

        <xsl:attribute name="data-tooltip-doc-override">
          <xsl:value-of select="'tooltip-enhanced'" />
        </xsl:attribute>

        <xsl:attribute name="data-text">
          <xsl:value-of select="'End Appendix'" />
        </xsl:attribute>
        <xsl:text> </xsl:text>
      </span>
    </span>
  </xsl:template>

  <xsl:template match="FURINF">
    <span class="further-info-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="further-info unprinted-element icon-fr2 icon-fr2-doc-generic cj-fancy-tooltip document-markup">
        <xsl:attribute name="data-tooltip-template">
          <xsl:value-of select="'#furinf-tooltip-template'" />
        </xsl:attribute>

        <xsl:attribute name="data-tooltip-doc-override">
          <xsl:value-of select="'tooltip-enhanced'" />
        </xsl:attribute>

        <xsl:attribute name="data-text">
          <xsl:value-of select="'Start Further Info'" />
        </xsl:attribute>
        <xsl:text> </xsl:text>
      </span>
    </span>

    <xsl:apply-templates />

    <span class="further-info-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="further-info unprinted-element icon-fr2 icon-fr2-doc-generic cj-fancy-tooltip document-markup">
        <xsl:attribute name="data-tooltip-template">
          <xsl:value-of select="'#furinf-tooltip-template'" />
        </xsl:attribute>

        <xsl:attribute name="data-tooltip-doc-override">
          <xsl:value-of select="'tooltip-enhanced'" />
        </xsl:attribute>

        <xsl:attribute name="data-text">
          <xsl:value-of select="'End Further Info'" />
        </xsl:attribute>
        <xsl:text> </xsl:text>
      </span>
    </span>
  </xsl:template>

</xsl:stylesheet>
