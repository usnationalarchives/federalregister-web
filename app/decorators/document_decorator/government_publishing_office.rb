module DocumentDecorator::GovernmentPublishingOffice
  def gpo_raw_text_url
    govinfo_document_html_url(model)
  end
end
