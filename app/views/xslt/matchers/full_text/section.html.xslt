<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- CONTENTS tag
       - generally precedes SECTION tags and serves as a ToC for them -->
  <xsl:template match="CONTENTS">
    <div class="regulatory-table-of-contents">
      <dl class="fr-list fr-list-inline">
        <xsl:apply-templates />
      </dl>
    </div>
  </xsl:template>

  <xsl:template match="HD[ancestor::CONTENTS]">
    <lh>
      <xsl:variable name="level">
        <xsl:call-template name="header_level">
          <xsl:with-param name="source" select="@SOURCE"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:attribute name="class">
        <xsl:value-of select="concat('sectno-header sectno-header-', $level)" />
      </xsl:attribute>

      <xsl:apply-templates />
    </lh>
  </xsl:template>

  <xsl:template match="SECTNO[ancestor::CONTENTS]">
    <dt class="sectno sectno-citation">
      <xsl:variable name="section_number" select="."/>

      <xsl:attribute name="id">
        <xsl:value-of select="concat('sectno-citation-', $section_number)" />
      </xsl:attribute>

      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="concat('#sectno-reference-', $section_number)" />
        </xsl:attribute>

        <xsl:apply-templates />
      </a>
    </dt>
  </xsl:template>

  <xsl:template match="SUBJECT[ancestor::CONTENTS]">
    <dd class="sectno-subject">
      <xsl:apply-templates />
    </dd>
  </xsl:template>


  <!-- SECTION tag
       - generally follows a CONTENTS tags -->

  <xsl:template match="SECTION">
    <div class="section">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="SECTNO[ancestor::SECTION]">
    <div class="sectno sectno-reference">
      <xsl:variable name="section_number" select="translate(translate(.,'§ ',''),'&#x2009;','')"/>


      <xsl:attribute name="id">
        <xsl:value-of select="concat('sectno-reference-', $section_number)" />
      </xsl:attribute>

      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="concat('#sectno-citation-', $section_number)" />
        </xsl:attribute>

        <xsl:apply-templates />
      </a>
    </div>
  </xsl:template>

  <xsl:template match="SUBJECT[ancestor::SECTION]">
    <div class="section-subject">
      <xsl:apply-templates />
    </div>
  </xsl:template>

</xsl:stylesheet>
