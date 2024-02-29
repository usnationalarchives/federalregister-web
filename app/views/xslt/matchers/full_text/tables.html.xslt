<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:esi="http://www.edge-delivery.org/esi/1.0"
    exclude-result-prefixes="esi"
    xmlns:fr="http://federalregister.gov/functions"
    extension-element-prefixes="fr"
    version="1.0">
  <xsl:output method="html" omit-xml-declaration="yes" />
  <xsl:template match="GPOTABLE">
    <xsl:copy-of select="fr:convert_table(.)" />
  </xsl:template>
</xsl:stylesheet>
