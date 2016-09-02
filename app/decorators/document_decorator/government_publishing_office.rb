module DocumentDecorator::GovernmentPublishingOffice
  def gpo_raw_text_url
    "https://www.gpo.gov/fdsys/pkg/FR-#{publication_date.to_s(:ymd_dash)}/html/#{document_number}.htm"
  end
end
