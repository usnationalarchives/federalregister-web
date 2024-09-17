<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fr="http://federalregister.gov/functions" extension-element-prefixes="fr">

  <xsl:template name="document_headings" match="AGENCY">
    <!-- only a few known instances of these print page inside the agency header
      (essentially the beginning of the document) and we want them to appear
      outside the document headings box - see C2-3011, 05-8393, Z6-18150 -->
    <xsl:apply-templates select="./PRTPAGE"/>

    <!-- create the document heading wrapper if this is the first AGENCY tag -->
    <xsl:if test="count(preceding-sibling::*[self::AGENCY]) = 0">
      <div class="document-headings">
        <div class="fr-box fr-box-published-alt no-footer">
          <div class="fr-seal-block fr-seal-block-header with-hover">
            <div class="fr-seal-content">
              <span class="h6">Document Headings</span>
              <div class="fr-seal-meta">
                <div class="fr-seal-desc">
                  <p>
                    Document headings vary by document type but may contain
                    the following:
                  </p>
                  <ol class="bullets">
                    <li>
                      the agency or agencies that issued and signed a document
                    </li>
                    <li>
                      the number of the CFR title and the number of each part
                      the document amends, proposes to amend, or is directly
                      related to
                    </li>
                    <li>
                      the agency docket number / agency internal file number
                    </li>
                    <li>
                      the RIN which identifies each regulatory action listed in
                      the Unified Agenda of Federal Regulatory and Deregulatory
                      Actions
                    </li>
                  </ol>
                  <p>
                    See the
                    <a href="https://www.archives.gov/files/federal-register/write/handbook/ddh.pdf#page=9">
                      Document Drafting Handbook
                    </a>
                    for more details.
                  </p>
                </div>
              </div>
            </div>
          </div>
          <div class="content-block ">
            <xsl:apply-templates select="//AGENCY" mode="document_headings"/>
          </div>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="document_headings" match="AGENCY">
    <!-- proceed if the agency header has content or
      is followed by a SUBAGY tag with content -->
    <xsl:if test="(string-length(text()) &gt; 0)
      or (
        (count(following-sibling::*[1][self::SUBAGY]) &gt; 0)
        and (
          string-length(
            following-sibling::*[1][self::SUBAGY]/text()
          ) &gt; 0
        )
      )">
      <xsl:variable name="agencyNodeID" select="generate-id(.)"/>

      <!-- only output the AGY tag if it has content -->
      <xsl:if test="string-length(text()) &gt; 0">
        <h6 class="agency">
          <xsl:copy-of select="fr:capitalize_most_words(text(), $document_number, $publication_date)"/>
        </h6>
      </xsl:if>


      <!-- select the following SUBAGY tags whose preceeding sibling AGENCY tag
        is the same as the one we're currently processing -->
      <xsl:for-each select="following-sibling::*[self::SUBAGY][generate-id(preceding-sibling::AGENCY[1]) = $agencyNodeID]">
        <xsl:apply-templates select="." mode="document_headings"/>
      </xsl:for-each>

      <!-- only output the ol tag if it will have content -->
      <xsl:if test="count(
        following-sibling::*[self::CFR|self::DEPDOC|self::RIN][generate-id(preceding-sibling::AGENCY[1]) = $agencyNodeID]
      ) &gt; 0">
        <ol>
          <!-- select the following CFR, DEPDOC, RIN, tags whose preceeding sibling
            AGENCY tag is the same as the one we're currently processing -->
          <xsl:for-each select="following-sibling::*[self::CFR|self::DEPDOC|self::RIN][generate-id(preceding-sibling::AGENCY[1]) = $agencyNodeID]">
            <xsl:apply-templates select="." mode="document_headings"/>
          </xsl:for-each>
        </ol>
       </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="document_headings" match="SUBAGY">
    <h6 class="sub-agency">
      <xsl:apply-templates />
    </h6>
  </xsl:template>

  <xsl:template mode="document_headings" match="CFR | DEPDOC | RIN">
    <li><xsl:value-of select="."/></li>
  </xsl:template>
</xsl:stylesheet>
