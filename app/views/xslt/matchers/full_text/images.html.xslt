<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:include href="../../templates/utils.html.xslt" />

  <xsl:template match="GPH/GID">
    <xsl:choose>
      <xsl:when test="contains($image_identifiers, text())">
        <p class="document-graphic">
          <a class="document-graphic-link">
            <xsl:attribute name="data-width">
              <xsl:value-of select="parent::GPH/@SPAN" />
            </xsl:attribute>
            <xsl:attribute name="data-height">
              <xsl:value-of select="parent::GPH/@DEEP" />
            </xsl:attribute>

            <xsl:attribute name="id">
              <xsl:value-of select="concat('g-', count(preceding::GPH/GID)+1)" />
            </xsl:attribute>

            <xsl:attribute name="href">
              <xsl:call-template name="graphic_url">
                <xsl:with-param name="style" select="'original'" />
                <xsl:with-param name="identifier" select="text()" />
              </xsl:call-template>
            </xsl:attribute>
            <img>
              <xsl:attribute name="src">
                <xsl:call-template name="graphic_url">
                  <xsl:with-param name="style" select="'large'" />
                  <xsl:with-param name="identifier" select="text()" />
                </xsl:call-template>
              </xsl:attribute>

              <xsl:attribute name="class">
                <xsl:if test="number(parent::GPH/@SPAN) = 3">
                  <xsl:value-of select="'document-graphic-image full'" />
                </xsl:if>
                <xsl:if test="number(parent::GPH/@SPAN) = 1">
                  <xsl:value-of select="'document-graphic-image small'" />
                </xsl:if>
              </xsl:attribute>
            </img>
          </a>
        </p>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Missing</xsl:text>
        <!--<xsl:call-template name="missing_graphic" />-->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="graphic_url">
    <xsl:param name="style" />
    <xsl:param name="identifier" />

    <xsl:variable name="style_url">
      <xsl:call-template name="string_replace_all">
        <xsl:with-param name="text" select="$image_base_url" />
        <xsl:with-param name="replace" select="':style'" />
        <xsl:with-param name="by" select="$style" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="url">
      <xsl:call-template name="string_replace_all">
        <xsl:with-param name="text" select="$style_url" />
        <xsl:with-param name="replace" select="':identifier'" />
        <xsl:with-param name="by" select="$identifier" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:value-of select="$url" />
  </xsl:template>
</xsl:stylesheet>
