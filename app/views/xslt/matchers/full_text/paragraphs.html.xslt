<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fr="http://federalregister.gov/functions" extension-element-prefixes="fr">
  <xsl:include href="../../templates/paragraphs.html.xslt" />
  <xsl:include href="../../templates/printed_page.html.xslt" />

  <xsl:template match="P[not(ancestor::AUTH)] | P[not(ancestor::LSTSUB)] | FP[not(@*)]">
    <!--
    <xsl:choose>
      <xsl:when test="starts-with(text(),'&#x2022;')">
        <xsl:if test="not(preceding-sibling::*[name() != 'PRTPAGE'][1][starts-with(text(),'&#x2022;')])">
          <xsl:value-of disable-output-escaping="yes" select="'&lt;ul class=&quot;bullets&quot;&gt;'"/>
        </xsl:if>
        <li>
          <xsl:attribute name="id">
            <xsl:call-template name="paragraph_id" />
          </xsl:attribute>
          <xsl:attribute name="data-page">
            <xsl:call-template name="current_page" />
          </xsl:attribute>
          <xsl:apply-templates />
        </li>
        <xsl:if test="not(following-sibling::*[name() != 'PRTPAGE'][1][starts-with(text(),'&#x2022;') and (name() = 'P' or name() = 'FP')])">
          <xsl:value-of disable-output-escaping="yes" select="'&lt;/ul&gt;'"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise> -->
        <p>
          <xsl:attribute name="id">
            <xsl:call-template name="paragraph_id" />
          </xsl:attribute>

          <xsl:attribute name="data-page">
            <xsl:call-template name="printed_page" />
          </xsl:attribute>

          <!--
          <xsl:if test="name(..) = 'FURINF'">
            <xsl:attribute name="class">furinf</xsl:attribute>
          </xsl:if> -->

          <xsl:apply-templates />
        </p>
        <!-- </xsl:otherwise>
    </xsl:choose> -->
  </xsl:template>

  <xsl:template match="FP[@SOURCE='FP-1']">
    <p class="flush-paragraph flush-paragraph-1">
      <xsl:attribute name="id">
        <xsl:call-template name="paragraph_id" />
      </xsl:attribute>

      <xsl:attribute name="data-page">
        <xsl:call-template name="printed_page" />
      </xsl:attribute>

      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="FP[@SOURCE='FP-2']">
    <p class="flush-paragraph flush-paragraph-2">
      <xsl:attribute name="id">
        <xsl:call-template name="paragraph_id" />
      </xsl:attribute>

      <xsl:attribute name="data-page">
        <xsl:call-template name="printed_page" />
      </xsl:attribute>

      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="FP[@SOURCE='FP1-2']">
    <p class="flush-paragraph flush-paragraph-1-2">
      <xsl:attribute name="id">
        <xsl:call-template name="paragraph_id" />
      </xsl:attribute>

      <xsl:attribute name="data-page">
        <xsl:call-template name="printed_page" />
      </xsl:attribute>

      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="FP[@SOURCE='FP-DASH']">
    <p>
      <xsl:attribute name="id">
        <xsl:call-template name="paragraph_id" />
      </xsl:attribute>

      <xsl:attribute name="data-page">
        <xsl:call-template name="printed_page" />
      </xsl:attribute>

      <xsl:attribute name="class">
        <xsl:if test="string-length(.) &gt; 50">flush-paragraph flush-paragraph-dash</xsl:if>
        <xsl:if test="string-length(.) &lt;= 50">flush-paragraph flush-paragraph-dash flush-paragraph-no-wrap</xsl:if>
      </xsl:attribute>

      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="FP[
    not(@SOURCE='FP-DASH')
    and (
      following-sibling::*[1][self::FP][@SOURCE='FP-DASH']
      or
      preceding-sibling::*[1][self::FP][@SOURCE='FP-DASH']
    )
    ]">
    <p class="flush-paragraph">
      <xsl:attribute name="id">
        <xsl:call-template name="paragraph_id" />
      </xsl:attribute>

      <xsl:attribute name="data-page">
        <xsl:call-template name="printed_page" />
      </xsl:attribute>

      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="P[ancestor::AUTH]">
    <span class="auth-content">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="P[ancestor::LSTSUB]">
    <div class="subject-list">
      <xsl:copy-of select="fr:list_of_subjects(text())"/>
    </div>
  </xsl:template>

</xsl:stylesheet>
