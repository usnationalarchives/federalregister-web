module RouteBuilder::ExternalUrls
  extend RouteBuilder::Utils

  def regulations_dot_gov_docket_url(docket_id)
    "https://www.regulations.gov/docket?D=#{docket_id}"
  end

  def regulations_dot_gov_docket_comments_url(docket_id)
    "https://www.regulations.gov/docketBrowser?rpp=50&so=DESC&sb=postedDate&po=0&dct=PS&D=#{docket_id}"
  end

  def regulations_dot_gov_docket_supporting_documents_url(docket_id)
    "https://www.regulations.gov/docketBrowser?rpp=50&po=0&dct=SR&D=#{docket_id}"
  end

  def regulations_dot_gov_supporting_document_url(document_id)
    "https://www.regulations.gov/document?D=#{document_id}"
  end

  def fdsys_document_issue_pdf_url(date)
    "https://www.gpo.gov/fdsys/pkg/FR-#{date.to_s(:to_s)}/pdf/FR-#{date.to_s(:to_s)}.pdf"
  end

  def fdsys_document_pdf_url(document)
    "https://www.gpo.gov/fdsys/pkg/FR-#{document.publication_date.to_s(:iso)}/pdf/#{document.document_number}.pdf"
  end

  def fdsys_document_mods_url(document)
    "https://www.gpo.gov/fdsys/granule/FR-#{document.publication_date.to_s(:iso)}/#{document.document_number}/mods.xml"
  end

  def fdsys_cfr_url(title, part, section)
    "http://api.fdsys.gov/link?collection=cfr&titlenum=#{title}&partnum=#{part}&sectionnum=#{section}&year=mostrecent&link-type=xml"
  end
end
