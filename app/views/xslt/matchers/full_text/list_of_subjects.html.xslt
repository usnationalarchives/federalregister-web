<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fr="http://federalregister.gov/functions" extension-element-prefixes="fr">

  <xsl:template match="LSTSUB">
    <span class="list-of-subjects-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="list-of-subjects unprinted-element cj-fancy-tooltip document-markup">
        <xsl:attribute name="data-tooltip-template">
          <xsl:value-of select="'#lstsub-tooltip-template'" />
        </xsl:attribute>

        <xsl:attribute name="data-tooltip-doc-override">
          <xsl:value-of select="'tooltip-enhanced'" />
        </xsl:attribute>

        <xsl:attribute name="data-text">
          <xsl:value-of select="'Start List of Subjects'" />
        </xsl:attribute>

        <span class="icon-fr2 icon-fr2-source_code"></span>
        <span class="text">
          <xsl:text>Start List of Subjects</xsl:text>
        </span>
      </span>
      <span class="unprinted-element-border"></span>
    </span>

    <xsl:apply-templates />

    <span class="list-of-subjects-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="list-of-subjects unprinted-element cj-fancy-tooltip document-markup">
        <xsl:attribute name="data-tooltip-template">
          <xsl:value-of select="'#lstsub-tooltip-template'" />
        </xsl:attribute>

        <xsl:attribute name="data-tooltip-doc-override">
          <xsl:value-of select="'tooltip-enhanced'" />
        </xsl:attribute>

        <xsl:attribute name="data-text">
          <xsl:value-of select="'End List of Subjects'" />
        </xsl:attribute>

        <span class="icon-fr2 icon-fr2-source_code"></span>
        <span class="text">
          <xsl:text>End List of Subjects</xsl:text>
        </span>
      </span>
      <span class="unprinted-element-border"></span>
    </span>
  </xsl:template>

  <xsl:template match="CFR[ancestor::LSTSUB]">
    <xsl:variable name="header_content">
      <xsl:apply-templates />
    </xsl:variable>

    <xsl:call-template name="manual_header">
      <xsl:with-param name="name">
        <xsl:apply-templates />
      </xsl:with-param>
      <xsl:with-param name="level" select="3"/>
      <xsl:with-param name="class" select="'cfr-subjects'"/>
      <xsl:with-param name="id" select="concat('los-cfr-', count(preceding::CFR[ancestor::LSTSUB])+1)" />
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
