class TableOfContentsPresenter
  attr_reader :table_of_contents_data, :date

  def initialize(date)#="February 25, 2015")
    @date = date.to_date
    @table_of_contents_data = HTTParty.get(url)
    # Example of Static JSON
    # url = 'http://localhost:3000/documents/table_of_contents/json/2015/02/25.json'
  end

  def url
    base_uri =
      if Rails.env.development?
        Settings.federal_register.base_uri
      else
        'https://www.federalregister.gov'
      end
    base_uri + "/documents/table_of_contents/json/#{date.strftime('%Y')}/#{date.strftime('%m')}/#{date.strftime('%d')}.json"
  end

  def lookup_document(doc_number)
    api_documents.results.find{|doc| doc.document_number == doc_number}
  end

  def agencies
    table_of_contents_data["agencies"]
  end

  def agency_count(agency_slug)
    agency_counts[agency_slug][:count]
  end

  def agency_counts
    @agency_info ||= begin
      hsh = {}
      agencies.map do |agency|
        doc_count=0
        agency["document_categories"].each do |doc_cat|
          doc_cat["documents"].each do |doc|
            doc_count += doc["document_numbers"].size 
          end
        end
        hsh[agency["slug"]] = {name: agency["name"] ,count: doc_count }
      end
      hsh
    end
  end

  def documents
    api_documents
  end

  def page_count(start_page, end_page)
    end_page - start_page + 1
  end

  private

  def api_documents
    @documents ||= Document.search(QueryConditions.published_on(date.to_date).
      merge(per_page: 1000, fields: ['start_page', 'end_page', 'pdf_url','document_number','html_url'])
    )
  end

end