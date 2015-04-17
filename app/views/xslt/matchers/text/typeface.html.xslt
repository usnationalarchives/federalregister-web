<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:include href="../../templates/formatting.html.xslt" />
  <xsl:include href="../../templates/whitespace.html.xslt" />

  <xsl:template match="E[@T=02]">
    <xsl:call-template name="optional_preceding_whitespace" />
    <strong class="minor-caps">
      <xsl:apply-templates />
    </strong>
    <xsl:call-template name="optional_following_whitespace" />
  </xsl:template>

  <xsl:template match="E[@T=03]">
    <xsl:call-template name="optional_preceding_whitespace" />
    <em>
      <xsl:apply-templates />
    </em>
    <xsl:call-template name="optional_following_whitespace" />
  </xsl:template>

  <xsl:template match="E[@T=04]">
    <xsl:call-template name="optional_preceding_whitespace" />
    <strong>
      <xsl:apply-templates />
    </strong>
    <xsl:call-template name="optional_following_whitespace" />
  </xsl:template>

  <xsl:template match="E[@T=34]">
    <xsl:call-template name="optional_preceding_whitespace" />
    <span class="small-caps">
      <xsl:apply-templates />
    </span>
    <xsl:call-template name="optional_following_whitespace" />
  </xsl:template>



  <!--  trim the trailing whitespace from the text element directly
        preceeding a subscript so that the subscript is positioned correctly -->
  <xsl:template match="text()[
      following-sibling::*[1][self::E][@T=51 or @T=52 or @T=53 or @T=54]
    ]">
    <xsl:call-template name="string-rtrim">
      <xsl:with-param name="string" select="." />
    </xsl:call-template>
  </xsl:template>

  <!--  trim the preceding whitespace from the text element directly following
        a subscript if it starts with a ', | ; | : | ) | ] so that the text
        is position correctly -->
  <xsl:template match="text()[
      preceding-sibling::*[1][self::E][@T=51 or @T=52 or @T=53 or @T=54]
      and
      contains(',;:)]', substring(normalize-space(.),1,1))
    ]">
    <xsl:call-template name="string-ltrim">
      <xsl:with-param name="string" select="." />
    </xsl:call-template>
  </xsl:template>

  <!--contains(',;:)]', substring(normalize-space(.),1,1)-->

  <!--  trim the whitespace from the text element directly following
        a subscript and directly preceding another subscript if it starts
        with a ', | ; | : | ) | ]' so that the subscript and the text
        are positioned correctly -->
  <xsl:template match="text()[
      following-sibling::*[1][self::E][@T=51 or @T=52 or @T=53 or @T=54]
      and
      preceding-sibling::*[1][self::E][@T=51 or @T=52 or @T=53 or @T=54]
      and
      contains(',;:)]', substring(normalize-space(.),1,1))
    ]">
    <xsl:call-template name="string-trim">
      <xsl:with-param name="string" select="." />
    </xsl:call-template>
  </xsl:template>


  <xsl:template match="E[@T=51]">
    <sup>
      <xsl:apply-templates />
    </sup>
  </xsl:template>

  <xsl:template match="E[@T=52]">
    <sub>
      <xsl:apply-templates />
    </sub>
  </xsl:template>

  <xsl:template match="E[@T=53]">
    <sup>
      <em>
        <xsl:apply-templates />
      </em>
    </sup>
  </xsl:template>

  <xsl:template match="E[@T=54]">
    <sub>
      <em>
        <xsl:apply-templates />
      </em>
    </sub>
  </xsl:template>

  <!--
    text italicised in header
    See page 9 here: http://www.gpo.gov/fdsys/pkg/FR-2015-01-22/pdf/2015-00344.pdf
  -->
  <xsl:template match="E[@T=7462]">
    <!--<xsl:call-template name="optional_preceding_whitespace" />-->
    <em>
      <xsl:apply-templates />
    </em>
    <!--<xsl:call-template name="optional_following_whitespace" />-->
  </xsl:template>

</xsl:stylesheet>
