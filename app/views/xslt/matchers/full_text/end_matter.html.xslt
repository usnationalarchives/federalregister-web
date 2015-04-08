<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template mode="end_matter" match="FRDOC">
    <p class="frdoc">
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template mode="end_matter" match="BILCOD">
    <p class="billing-code">
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template name="end_matter">
    <xsl:if test="count(//FRDOC | //BILCOD) &gt; 0">
      <div class="end-matter">
        <xsl:apply-templates select="//FRDOC | //BILCOD" mode="end_matter"/>
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
