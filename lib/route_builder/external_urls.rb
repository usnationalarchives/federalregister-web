module RouteBuilder::ExternalUrls
  extend RouteBuilder::Utils

  #
  # REGULATIONS.GOV URLS
  #

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


  #
  # FEDERAL REGISTER URLS
  #

  def govinfo_document_issue_pdf_url(date)
    "https://www.govinfo.gov/content/pkg/FR-#{date.to_s(:to_s)}/pdf/FR-#{date.to_s(:to_s)}.pdf"
  end

  def govinfo_document_issue_pdf_url(document)
    gov_info_fr_document_url(document, 'pdf')
  end

  def govinfo_document_mods_url(document)
    gov_info_fr_document_url(document, 'mods')
  end

  def govinfo_document_html_url(document)
    gov_info_fr_document_url(document, 'html')
  end

  def gov_info_fr_document_url(document, type)
    "#{gov_info_link_service('fr')}/#{document.document_number}?link-type=#{type}"
  end


  #
  # CFR URLS
  #

  def govinfo_cfr_xml_url(title, part, section)
    govinfo_cfr_url(title, part, section, 'xml')
  end

  def govinfo_cfr_pdf_url(title, part, section)
    govinfo_cfr_url(title, part, section, 'pdf')
  end

  def govinfo_cfr_url(title, part, section, type)
    "#{gov_info_link_service('cfr')}/#{title}/#{part}?sectionnum=#{section}&year=mostrecent&link-type=#{type}"
  end


  #
  # PUBLIC LAW URLS
  #

  def govinfo_public_law_pdf_url(congress, law)
    govinfo_public_law_url(congress, law, 'pdf')
  end

  def govinfo_public_law_url(congress, law, type)
    "#{gov_info_link_service('plaw')}/#{congress}/public/#{law}?link-type=#{type}"
  end


  #
  # USC URLS
  #

  def govinfo_usc_pdf_url(title, section)
    govinfo_usc_url(title, section, 'pdf')
  end

  def govinfo_usc_url(title, section, type)
    "#{gov_info_link_service('uscode')}/#{title}/#{section}?type=usc&year=mostrecent&link-type=#{type}"
  end


  #
  # BASE URLS
  #

  def gov_info_link_service(service)
    "https://www.govinfo.gov/link/#{service}"
  end
end
