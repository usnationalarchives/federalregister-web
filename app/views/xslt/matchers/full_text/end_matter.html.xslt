<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template mode="end_matter" match="FRDOC">
    <p class="frdoc">
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:key name="kBillCodeByText" match="BILCOD" use="text()"/>

  <!-- match the first occurance of a billing code and output as a p -->
  <xsl:template mode="end_matter" match="BILCOD[
    generate-id() = generate-id(
      key('kBillCodeByText', text())[1]
    )
  ]">
    <p class="billing-code">
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <!-- match subsequent occuranced of a billing code and suppress -->
  <xsl:template mode="end_matter" match="BILCOD[not(
    generate-id() = generate-id(
      key('kBillCodeByText', text())[1]
    )
  )]" />

  <xsl:template name="end_matter">
    <xsl:if test="count(//FRDOC | //BILCOD) &gt; 0">
      <div class="end-matter">
        <xsl:apply-templates select="//FRDOC | //BILCOD" mode="end_matter"/>
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
