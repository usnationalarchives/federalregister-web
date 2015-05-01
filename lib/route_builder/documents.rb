module RouteBuilder::Documents
  extend RouteBuilder::Utils

  add_route :document do |document|
    date = date_from_object(document)
    {
      year:             date.strftime('%Y'),
      month:            date.strftime('%m'),
      day:              date.strftime('%d'),
      document_number:  document.document_number,
      slug:             document.slug,
    }
  end

  add_route :document_issue do |document_issue_or_document|
    date = date_from_object(document_issue_or_document)
    {
      year:   date.strftime('%Y'),
      month:  date.strftime('%m'),
      day:    date.strftime('%d'),
    }
  end

  add_route :short_document do |document|
    {
      document_number: document.document_number,
    }
  end

  add_static_route :document_table_of_contents do |document|
    file_path = document.body_html_url.split('full_text/').last

    "/documents/table_of_contents/#{file_path}"
  end

  add_static_route :document_api do |document|
    "/api/v1/documents/#{document.document_number}"
  end

  private

  def self.date_from_object(document_like_object)
    if document_like_object.is_a?(Date)
      document_like_object
    else
      (
        document_like_object.try(:publication_date) ||
        document_like_object.try(:filed_at) ||
        Date.current
      ).to_date
    end
  end
end
