<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" omit-xml-declaration="yes" />

  <xsl:include href="app/views/xslt/templates/diacriticals.html.xslt" />
  <xsl:include href="app/views/xslt/templates/formatting.html.xslt" />
  <xsl:include href="app/views/xslt/templates/ignored_nodes.html.xslt" />

  <xsl:include href="app/views/xslt/matchers/full_text/headers.html.xslt" />
  <xsl:include href="app/views/xslt/matchers/full_text/paragraphs.html.xslt" />

  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>
</xsl:stylesheet>
