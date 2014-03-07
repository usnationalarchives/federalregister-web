module RouteBuilder::PublicInspectionDocuments
  extend RouteBuilder::Utils

  add_route :public_inspection_documents do |date|
    {
      year:   date.strftime('%Y'),
      month:  date.strftime('%m'),
      day:    date.strftime('%d'),
    }
  end
end
