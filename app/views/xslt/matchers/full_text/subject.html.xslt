<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="SUBJECT[not(ancestor::CONTENTS) and not(ancestor::SECTION)]">
    <xsl:call-template name="manual_header">
      <xsl:with-param name="name" select="'SUBJECT'"/>
      <xsl:with-param name="level" select="1"/>
      <xsl:with-param name="class" select="'document-subject'"/>
    </xsl:call-template>

    <p>
      <xsl:attribute name="id">
        <xsl:call-template name="paragraph_id" />
      </xsl:attribute>

      <xsl:attribute name="data-page">
        <xsl:call-template name="printed_page" />
      </xsl:attribute>

      <xsl:apply-templates />
    </p>
  </xsl:template>

</xsl:stylesheet>
