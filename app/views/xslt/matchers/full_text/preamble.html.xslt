<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:template match="PREAMB">
    <div class="preamble">
      <!-- only apply templates for the headers we want to process, other tags
        in the preamble will get hoisted into their preceding header -->
      <xsl:apply-templates select="AGENCY" />

      <xsl:choose>
        <!-- many notices and all prorule and rule docs -->
        <xsl:when test="count(child::ACT | child::ADD | child::AGY | child::DATES | child::EFFDATE | child::FURINF | child::SUM) &gt; 0">
          <xsl:apply-templates select="ACT | ADD | AGY | DATES | EFFDATE | FURINF | SUM"/>
        </xsl:when>
        <!-- some notice documents docs -->
        <xsl:otherwise>
          <xsl:apply-templates select="*[not(self::AGENCY)]" />
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template match="ACT | ADD | AGY | DATES | EFFDATE | FURINF | SUM">
    <xsl:variable name="headerText" select="./HD[@SOURCE='HED'][1]/text()" />

    <div>
      <xsl:attribute name="id">
        <xsl:call-template name="convertToIdOrClass">
          <xsl:with-param name="text" select="substring-before($headerText, ':')" />
        </xsl:call-template>
      </xsl:attribute>

      <!-- generate the id for this node for comparison later -->
      <xsl:variable name="tagId" select="generate-id(.)"/>

      <xsl:apply-templates />

      <!-- Any immediately following paragraphs that aren't in a tag are moved
        into this tag. This fixes edge cases where the markup didn't wrap all
        paragraphs (there should be no tags in the Preamble that aren't in one
        of these sections). -->
      <xsl:for-each select="following-sibling::*[not(self::ACT | self::ADD | self::AGY | self::DATES | self::EFFDATE | self::FURINF | self::SUM)]
        [
          generate-id(
            preceding-sibling::*[self::ACT | self::ADD | self::AGY | self::DATES | self::EFFDATE | self::FURINF | self::SUM][1]
          ) = $tagId
        ]">
        <xsl:apply-templates select="." />
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="PREAMHD">
    <xsl:variable name="headerText" select="./HD[@SOURCE='HED'][1]/text()" />

    <div>
      <xsl:attribute name="id">
        <xsl:call-template name="convertToIdOrClass">
          <xsl:with-param name="text" select="substring-before($headerText, ':')" />
        </xsl:call-template>
      </xsl:attribute>

      <xsl:apply-templates />
    </div>
  </xsl:template>
</xsl:stylesheet>
