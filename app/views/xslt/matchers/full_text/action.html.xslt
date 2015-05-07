<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="ACT">
    <xsl:call-template name="manual_header">
      <xsl:with-param name="name" select="'ACTION'"/>
      <xsl:with-param name="level" select="1"/>
      <xsl:with-param name="class" select="'document-action'"/>
    </xsl:call-template>

    <xsl:apply-templates />
  </xsl:template>

</xsl:stylesheet>

