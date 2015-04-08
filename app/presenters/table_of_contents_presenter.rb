class TableOfContentsPresenter
  attr_reader :table_of_contents_data

  def initialize(date=nil)
    url = 'http://localhost:3000/documents/table_of_contents/json/2015/02/25.json'
    #TODO: Dynamically generate url using Settings.federal_register.local, etc.
    @table_of_contents_data = HTTParty.get(url)
  end

  def lookup_document(doc_number)
    api_documents.results.find{|doc| doc.document_number == doc_number}
  end

  def agencies
    table_of_contents_data["agencies"]
  end

  def documents
    api_documents
  end

  def page_count(start_page, end_page)
    end_page - start_page + 1
  end

  private

  def api_documents
    @documents ||= Document.search(QueryConditions.published_on("February 25, 2015".to_date).
      merge(per_page: 1000, fields: ['start_page', 'end_page', 'pdf_url','document_number','html_url'])
    )
  end

end