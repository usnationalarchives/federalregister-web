module RouteBuilder::ExternalUrls
  extend RouteBuilder::Utils

  def regulations_dot_gov_docket_url(docket_id)
    "http://www.regulations.gov/#!docketDetail;rpp=100;so=DESC;sb=docId;po=0;D=#{docket_id}"
  end

  def regulations_dot_gov_docket_comments_url(docket_id)
    "http://www.regulations.gov/#!docketBrowser;dct=PS;rpp=100;so=DESC;sb=docId;po=0;D=#{docket_id}"
  end

  def regulations_dot_gov_docket_supporting_documents_url(docket_id)
    "http://www.regulations.gov/#!docketBrowser;dct=SR;rpp=100;so=DESC;sb=docId;po=0;D=#{docket_id}"
  end

  def regulations_dot_gov_supporting_document_url(document_id)
    "http://www.regulations.gov/#!documentDetail;D=#{document_id}"
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
