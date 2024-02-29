<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fr="http://federalregister.gov/functions" extension-element-prefixes="fr">

  <xsl:template match="LSTSUB">
    <div class="list-of-subjects">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="CFR[ancestor::LSTSUB]">
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
