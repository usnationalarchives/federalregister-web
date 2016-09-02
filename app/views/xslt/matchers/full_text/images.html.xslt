<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:fr="http://federalregister.gov/functions" extension-element-prefixes="fr">
  <xsl:include href="../../templates/utils.html.xslt" />


  <xsl:template match="GPH/GID | MATH/MID">
    <xsl:variable name="paragraph_id">
      <xsl:value-of select="concat('g-', count(preceding::GPH/GID)+count(preceding::MATH/MID)+1)" />
    </xsl:variable>

    <xsl:variable name="image_class">
      <xsl:if test="number(parent::GPH/@SPAN | parent::MATH/@SPAN) = 3">
        <xsl:value-of select="'document-graphic-image full'" />
      </xsl:if>
      <xsl:if test="number(parent::GPH/@SPAN | parent::MATH/@SPAN) = 1">
        <xsl:value-of select="'document-graphic-image small'" />
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="data_width">
      <xsl:if test="number(parent::GPH/@SPAN | parent::MATH/@SPAN) = 3">
        <xsl:value-of select="3" />
      </xsl:if>
      <xsl:if test="number(parent::GPH/@SPAN | parent::MATH/@SPAN) = 1">
        <xsl:value-of select="1" />
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="data_height">
      <xsl:value-of select="number(parent::GPH/@DEEP | parent::MATH/@DEEP)" />
    </xsl:variable>

    <p class="document-graphic">
      <xsl:copy-of select="fr:gpo_image(text(), $paragraph_id, $image_class, $data_width, $data_height, $images, $document_number, $publication_date)" />
    </p>
  </xsl:template>
</xsl:stylesheet>
