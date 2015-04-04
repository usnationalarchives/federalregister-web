<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:esi="http://www.edge-delivery.org/esi/1.0"
    exclude-result-prefixes="esi"
    version="1.0">
  <xsl:output method="html" omit-xml-declaration="yes" />
  <xsl:template match="GPOTABLE">
    <esi:include>
      <xsl:attribute name="src">
        <xsl:value-of select="concat(
            '/documents/tables/html/',
            translate($publication_date, '-', '/'),
            '/',
            $document_number,
            '/',
            count(preceding::GPOTABLE)+1,
            '.html'
          )" />
      </xsl:attribute>
    </esi:include>
  </xsl:template>
</xsl:stylesheet>
