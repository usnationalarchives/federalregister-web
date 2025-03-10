<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!--  GENERAL NOTE:
        Some of the following tags have match statements that look like
          AGY[count(child::P) &lt; 2]
        We only ignore these tags if they have only 1 child <P> node which
        is the normal case.
        Occasionally once of these tags is not properly closed in the XML,
        in those cases we don't want to ignore them or we would hide the rest
        of the document -->


  <!-- Ignore tags usually found in the preamble of a document <PREAMB>
       that we don't show as part of the document or display via other means -->

  <!-- These tags only contain text nodes -->
  <xsl:template match="SUBJECT" />

  <!-- These tags don't contain other child nodes so we'll ignore them too -->
  <!-- we no longer ignore AGY tags but left here for reference -->
  <!-- <xsl:template match="AGY[count(child::P) &lt; 2]" /> -->


  <!-- Ignore tags we handle explicitely elsewhere -->
  <xsl:template match="BILCOD | FRDOC | FTNT | FTREF | SUBAGY | CFR | DEPDOC | RIN" />

  <!-- Ignore tags usually found elsewhere in a document -->
  <xsl:template match="CNTNTS | UNITNAME | INCLUDES | EDITOR | EAR | FRDOCBP | HRULE | NOLPAGES | OLPAGES | SECHD | TITLE3 | PRES | NOPRINTSUBJECT | NOPRINTEONOTES" />

</xsl:stylesheet>
