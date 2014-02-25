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
end
