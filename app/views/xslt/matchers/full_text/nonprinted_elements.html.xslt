<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!--  These are elements that are marked up by OFR/GPO and
        delineate particular sections of the document, but are
        not printed. We offer these as an enhancement to aid the
        user in understanding the document. -->

  <!-- SIG nodes are handled in the signature matcher -->

  <xsl:template match="PREAMB">
    <div class="preamble">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="APPENDIX">
    <xsl:choose>
      <xsl:when test="parent::*[1][name() = 'REGTEXT']">
        <div class="appendix">
          <xsl:apply-templates />
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="FURINF">
    <div class="further-info">
      <xsl:apply-templates />
    </div>
  </xsl:template>

</xsl:stylesheet>
