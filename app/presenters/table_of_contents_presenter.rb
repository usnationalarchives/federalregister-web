class TableOfContentsPresenter
  attr_reader :table_of_contents_data, :date

  def initialize(date)
    @date = date.is_a?(Date) ? date : Date.parse(date)
    @table_of_contents_data = HTTParty.get(url)
  end

  def url
    "#{Settings.federal_register.base_uri}/document_issues/json/#{date.to_s(:ymd)}.json"
  end

  def document_partial
    'document_issues/table_of_contents_doc_details'
  end

  def agencies
    @agencies ||= table_of_contents_data["agencies"].inject({}) do |hsh, agency_hash|
      hsh[agency_hash['slug']] = Agency.new(agency_hash, self)
      hsh
    end
  end

  def documents
    @documents ||= Document.search(
      QueryConditions.published_on(date).
        merge(
         per_page: 1000,
          fields: [
            :document_number,
            :end_page,
            :html_url,
            :pdf_url,
            :publication_date,
            :start_page,
          ]
        )
    ).results.map{|d| DocumentDecorator.decorate(d)}
  end


  # DOCUMENT STATUS
  def official_documents?
    documents.first.official?
  end

  def document?
    documents.first.document?
  end


  # FR BOX RENDERING
  def fr_content_box_type
    if document?
      official_documents? ? :official_document_toc : :published_document_toc
    else
      :public_inspection_document_toc
    end
  end

  def fr_details_box_type
    if document?
      official_documents? ? :official_document_details : :published_document_details
    else
      :public_inspection_document_details
    end
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

    def load_documents(doc_numbers)
      doc_numbers.map do |doc_num|
        doc = documents[doc_num]

        unless doc
          Honeybadger.notify(
            error_class: "Missing document number for table of contents",
            error_message: "Document number #{doc_num} not found for #{name}"
          )
        end

        doc
      end.compact
    end

    private

    def document_numbers
      return @document_numbers if @document_numbers
      doc_numbers = []
      attributes["document_categories"].each do |doc_cat|
        doc_cat["documents"].each do |doc|
          doc_numbers << doc["document_numbers"]
        end
      end
      @document_numbers = doc_numbers.flatten
    end

    def documents
      @documents ||= document_numbers.inject({}) do |hsh, doc_num|
        hsh[doc_num] = presenter.documents.find{|doc| doc.document_number == doc_num}
        hsh
      end
    end
  end
end
