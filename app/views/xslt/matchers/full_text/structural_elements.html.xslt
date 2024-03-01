<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fr="http://federalregister.gov/functions" extension-element-prefixes="fr">
  <!--  These are elements that are marked up by OFR/GPO and delineate
    particular sections of the document, but are not printed. Some have
    corresponding headers that do appear in the text and others do not.
    We offer these as an enhancement to aid the user in understanding
    structure of the document. -->

  <!-- Some nodes are handled in seperate files if they use more extensive
    handling -->

  <xsl:template match="AGY">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="ACT">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="AMDPAR">
    <p class="amendment-part">
      <xsl:attribute name="id">
        <xsl:call-template name="amdpar_paragraph_id" />
      </xsl:attribute>

      <xsl:apply-templates select="fr:amendment_part(child::node())"/>
    </p>
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

  <xsl:template match="AUTH">
    <p class="authority">
      <xsl:attribute name="id">
        <xsl:call-template name="paragraph_id" />
      </xsl:attribute>

      <xsl:attribute name="data-page">
        <xsl:call-template name="printed_page" />
      </xsl:attribute>

      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="FURINF">
    <div class="further-info">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="PART">
    <div class="part">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="PREAMB">
    <div class="preamble">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="SUBPART">
    <div class="subpart">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="SUPLINF">
    <div class="supplemental-info">
      <xsl:apply-templates />
    </div>
  </xsl:template>

</xsl:stylesheet>
