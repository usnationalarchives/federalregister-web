<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="text()">
    <xsl:variable name="text_content">
      <xsl:choose>
        <xsl:when test="starts-with(.,'&#x2022;') and (ancestor::P or ancestor::FP)">
          <!-- strip bullet and following space -->
          <xsl:value-of select="substring(.,3)" />
        </xsl:when>

        <xsl:otherwise>
          <xsl:value-of select="." />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <!--  trim the whitespace from the text element directly following
            a subscript and directly preceding another subscript if it starts
            with a ', | ; | : | ) | ]' so that the subscript and the text
            are positioned correctly -->
      <xsl:when test="
          following-sibling::*[1][self::E][@T=51 or @T=52 or @T=53 or @T=54]
          and
          preceding-sibling::*[1][self::E][@T=51 or @T=52 or @T=53 or @T=54]
          and
          contains(',;:)]', substring(normalize-space(.),1,1))
        ">
        <xsl:call-template name="string-trim">
          <xsl:with-param name="string" select="." />
        </xsl:call-template>
      </xsl:when>

      <!--  trim the trailing whitespace from the text element directly
            preceeding a subscript so that the subscript is positioned correctly -->
      <xsl:when test="
          following-sibling::*[1][self::E][@T=51 or @T=52 or @T=53 or @T=54]
          or
          following-sibling::*[1][self::SU]
        ">
        <xsl:call-template name="string-rtrim">
          <xsl:with-param name="string" select="$text_content" />
        </xsl:call-template>
      </xsl:when>

      <!--  trim the preceding whitespace from the text element directly following
            a subscript if it starts with a ', | ; | : | ) | ] so that the text
            is position correctly -->
      <xsl:when test="
          preceding-sibling::*[1][self::E][@T=51 or @T=52 or @T=53 or @T=54]
          and
          contains(',;:)]', substring(normalize-space(.),1,1))
        ">
        <xsl:call-template name="string-ltrim">
          <xsl:with-param name="string" select="$text_content" />
        </xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select="$text_content" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
