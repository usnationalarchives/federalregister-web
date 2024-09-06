<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <!--  used to replace text in a string as XSLT 1.0 doesn't have a
        replace function.
        Usage:
        <xsl:variable name="newtext">
          <xsl:call-template name="string-replace-all">
            <xsl:with-param name="text" select="$text" />
            <xsl:with-param name="replace" select="a" />
            <xsl:with-param name="by" select="b" />
          </xsl:call-template>
        </xsl:variable>
      -->
  <xsl:template name="string_replace_all">
    <xsl:param name="text" />
    <xsl:param name="replace" />
    <xsl:param name="by" />
    <xsl:choose>
      <xsl:when test="contains($text, $replace)">
        <xsl:value-of select="substring-before($text,$replace)" />
        <xsl:value-of select="$by" />
        <xsl:call-template name="string_replace_all">
          <xsl:with-param name="text"
          select="substring-after($text,$replace)" />
          <xsl:with-param name="replace" select="$replace" />
          <xsl:with-param name="by" select="$by" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

  <xsl:template name="downcase">
    <xsl:param name="text" />
    <xsl:value-of select="translate($text, $uppercase, $lowercase)" />
  </xsl:template>

  <xsl:template name="upcase">
    <xsl:param name="text" />
    <xsl:value-of select="translate($text, $lowercase, $uppercase)" />
  </xsl:template>

  <xsl:template name="dasherize">
    <xsl:param name="text" />

    <xsl:variable name="dasherized">
      <xsl:call-template name="string_replace_all">
        <xsl:with-param name="text" select="$text" />
        <xsl:with-param name="replace" select="' '" />
        <xsl:with-param name="by" select="'-'" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:value-of select="$dasherized" />
  </xsl:template>

  <xsl:template name="convertToIdOrClass">
    <xsl:param name="text" />

    <xsl:variable name="downcased">
      <xsl:call-template name="downcase">
        <xsl:with-param name="text" select="$text" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="dasherized">
      <xsl:call-template name="dasherize">
        <xsl:with-param name="text" select="$downcased" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:value-of select="$dasherized" />
  </xsl:template>
</xsl:stylesheet>
