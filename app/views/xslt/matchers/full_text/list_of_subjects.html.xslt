<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fr="http://federalregister.gov/functions" extension-element-prefixes="fr">

  <xsl:template match="LSTSUB">
    <span class="list-of-subjects-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="list-of-subjects unprinted-element icon-fr2 icon-fr2-Molecular cj-tooltip">
        <xsl:attribute name="data-tooltip-template">
          <xsl:value-of select="'#lstsub-tooltip-template'" />
        </xsl:attribute>

        <xsl:attribute name="data-tooltip-doc-override">
          <xsl:value-of select="'tooltip-enhanced'" />
        </xsl:attribute>

        <xsl:attribute name="data-text">
          <xsl:value-of select="'Start List of Subjects'" />
        </xsl:attribute>
        <xsl:text> </xsl:text>
      </span>
      <span class="unprinted-element-border"></span>
    </span>

    <xsl:apply-templates />

    <span class="list-of-subjects-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="list-of-subjects unprinted-element icon-fr2 icon-fr2-Molecular cj-tooltip">
        <xsl:attribute name="data-tooltip-template">
          <xsl:value-of select="'#lstsub-tooltip-template'" />
        </xsl:attribute>

        <xsl:attribute name="data-tooltip-doc-override">
          <xsl:value-of select="'tooltip-enhanced'" />
        </xsl:attribute>
        
        <xsl:attribute name="data-text">
          <xsl:value-of select="'End List of Subjects'" />
        </xsl:attribute>
        <xsl:text> </xsl:text>
      </span>
      <span class="unprinted-element-border"></span>
    </span>
  </xsl:template>

  <xsl:template match="CFR[ancestor::LSTSUB]">
    <xsl:variable name="id">
      <xsl:call-template name="string_replace_all">
        <xsl:with-param name="text" select="text()" />
        <xsl:with-param name="replace" select="' '" />
        <xsl:with-param name="by" select="'-'" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:call-template name="manual_header">
      <xsl:with-param name="name" select="text()"/>
      <xsl:with-param name="level" select="3"/>
      <xsl:with-param name="class" select="'cfr-subjects'"/>
      <xsl:with-param name="id" select="concat('los-', $id)" />
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
