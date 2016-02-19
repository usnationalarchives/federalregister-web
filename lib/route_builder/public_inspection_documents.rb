module RouteBuilder::PublicInspectionDocuments
  extend RouteBuilder::Utils

  add_route :public_inspection_issue do |issue_or_document|
    date = date_from_object(issue_or_document)
    {
      year:   date.strftime('%Y'),
      month:  date.strftime('%m'),
      day:    date.strftime('%d'),
    }
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
