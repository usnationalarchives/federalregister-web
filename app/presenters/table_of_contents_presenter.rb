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
      hsh[agency_hash['slug']] = TableOfContentsPresenter::Agency.new(agency_hash, self)
      hsh
    end
  end

  def documents
    @documents ||= Document.search(
      QueryConditions.published_on(date).
        merge(
         per_page: 1000,
          fields: [
            :citation,
            :document_number,
            :end_page,
            :html_url,
            :pdf_url,
            :publication_date,
            :start_page,
            :title,
          ]
        )
    ).results.map{|d| DocumentDecorator.decorate(d)}
  end


  # DOCUMENT STATUS
  def official_documents?
    documents.first.official?
  end

  # special filing documents may not always be present so check first
  def document?
    documents.present? && documents.first.document?
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



    def documents
      @documents ||= document_numbers.inject({}) do |hsh, doc_num|
        hsh[doc_num] = presenter.documents.find{|doc| doc.document_number == doc_num}
        hsh
      end
    end
  end
end
