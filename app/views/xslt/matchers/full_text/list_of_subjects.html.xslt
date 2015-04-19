<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fr="http://federalregister.gov/functions" extension-element-prefixes="fr">

  <xsl:template match="P[ancestor::LSTSUB]">
    <div class="subject-list">
      <xsl:copy-of select="fr:list_of_subjects(text())"/>
    </div>
  </xsl:template>

</xsl:stylesheet>
