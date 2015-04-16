class TableOfContentsPresenter
  attr_reader :table_of_contents_data, :date

  def initialize(date)
    @date = date
    @table_of_contents_data = HTTParty.get(url)
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

  def document_partial
    'document_issues/table_of_contents_doc_details'
  end

  def lookup_document(doc_number)
    api_documents.results.find{|doc| doc.document_number == doc_number}
  end

  def agencies
    @agencies ||= table_of_contents_data["agencies"].inject({}) do |hsh, agency_hash|
      hsh[agency_hash['slug']] = Agency.new(agency_hash, self)
      hsh
    end
  end

  def documents
    api_documents
  end

  def page_count(start_page, end_page)
    end_page - start_page + 1
  end


  class Agency
    attr_reader :attributes, :presenter

    def initialize(attributes, presenter)
      @attributes = attributes
      @presenter = presenter
    end

    def name
      attributes['name']
    end

    def slug
      attributes['slug']
    end

    def to_param
      slug
    end

    def child_agencies
      if attributes['see_also']
        @child_agencies ||= attributes['see_also'].map do |child_agency|
          presenter.agencies[child_agency['slug']]
        end
      else
        []
      end
    end

    def document_categories
      attributes["document_categories"]
    end

    def document_count_with_child_agencies
      return @document_count_with_child_agencies if @document_count_with_child_agencies

      @document_count_with_child_agencies = child_agencies.inject(document_count) do |sum, child_agency|
        sum += child_agency.document_count
        sum
      end
    end

    def document_count
      return @document_count if @document_count

      @document_count = attributes["document_categories"].inject(0) do |sum, doc_cat|
        doc_cat["documents"].each do |doc|
          sum += doc["document_numbers"].size
        end
        sum
      end
    end

    def find_specific_agency_documents(doc_numbers)
      doc_numbers.map {|doc_num| documents[doc_num]}
    end

    private

    def document_numbers
      return @document_numbers if @document_numbers
      doc_numbers = []
      attributes["document_categories"].each do |doc_cat| #TODO: Refactor to nested injects?
        doc_cat["documents"].each do |doc|
          doc_numbers << doc["document_numbers"]
        end
      end
      @document_numbers = doc_numbers.flatten
    end

    def documents
      @documents ||= document_numbers.inject({}) do |hsh, doc_num|
        hsh[doc_num] = presenter.documents.results.find{|doc| doc.document_number == doc_num}
        hsh
      end
    end

  end


  private

  def api_documents
    @documents ||= Document.search(QueryConditions.published_on(date.to_date).
      merge(per_page: 1000, fields: ['start_page', 'end_page', 'pdf_url','document_number','html_url'])
    )
  end

end