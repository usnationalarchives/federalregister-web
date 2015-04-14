module RouteBuilder::Documents
  extend RouteBuilder::Utils

  add_route :documents do |date|
    {
      year:   date.strftime('%Y'),
      month:  date.strftime('%m'),
      day:    date.strftime('%d'),
    }
  end

  add_route :document do |document|
    {
      year:             (document.publication_date || (document.filed_at || Date.current).to_date ).strftime('%Y'),
      month:            (document.publication_date || (document.filed_at || Date.current).to_date ).strftime('%m'),
      day:              (document.publication_date || (document.filed_at || Date.current).to_date ).strftime('%d'),
      document_number:  document.document_number,
      slug:             document.slug,
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
end
