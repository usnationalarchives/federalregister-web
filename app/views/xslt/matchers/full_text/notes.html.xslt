<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fr="http://federalregister.gov/functions" extension-element-prefixes="fr">
  <xsl:output method="html" omit-xml-declaration="yes"/>

  <xsl:template match="EDNOTE">
    <xsl:variable name="type" select="@TYPE"/>

    <div class="editorial-note">
      <div>
        <!-- determine box class -->
        <xsl:choose>
          <xsl:when test="$type = 'POSTPUB'">
            <xsl:attribute name="class">
              <xsl:value-of select="'fr-box fr-box-enhanced no-footer'" />
            </xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">
              <xsl:value-of select="'fr-box fr-box-published-alt no-footer'" />
            </xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>

        <div class="fr-seal-block fr-seal-block-header">
          <div class="fr-seal-content">
            <h6>
              <xsl:if test="$type = 'POSTPUB'">Enhanced Content - </xsl:if>
              Editorial Note
            </h6>
          </div>
        </div>
        <div class="content-block ">
          <xsl:apply-templates select="*[self::HD]" mode="notes"/>
          <xsl:apply-templates select="*[not(self::HD)]" mode="notes"/>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="HD" mode="notes">
    <h4 class="inline-header">
      <xsl:copy-of select="fr:capitalize_most_words(text())"/>
    </h4>
  </xsl:template>

  <xsl:template match="P" mode="notes">
    <p class="inline-paragraph">
      <xsl:apply-templates />
    </p>
  </xsl:template>
</xsl:stylesheet>
