class TableOfContentsPresenter
  attr_reader :table_of_contents_data, :date, :filter_to_documents

  def initialize(date, filter_to_documents=nil)
    @date = date.is_a?(Date) ? date : Date.parse(date)
    @table_of_contents_data = retrieve_toc_data
    @filter_to_documents = filter_to_documents
  end

  def retrieve_toc_data
    HTTParty.get(url)
  end

  def url
    "#{Settings.federal_register.base_uri}/document_issues/json/#{date.to_s(:ymd)}.json"
  end

  def document_partial
    'document_issues/document_details'
  end

  def agencies
    filter_to_documents.present? ? filtered_agencies : raw_agencies
  end

  def filtered_agency_slugs
    # grabbing only the child agency slugs
    @filtered_agency_slugs ||= documents.map do |document|
      document.excluding_parent_agencies.map(&:slug)
    end.flatten.uniq
  end

  def document_numbers
    filter_to_documents.present? ? filtered_document_numbers : raw_document_numbers
  end

  def documents
    retrieve_documents.results.map{|d| DocumentDecorator.decorate(d)}
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

  private

  def retrieve_documents
    @documents ||= Document.find_all(
      document_numbers,
      {
        per_page: 1000,
        fields: document_fields
      }
    )
  end

  def document_fields
    [
      :agencies,
      :citation,
      :document_number,
      :end_page,
      :html_url,
      :pdf_url,
      :publication_date,
      :start_page,
      :title,
    ]
  end

  def raw_document_numbers
    return @raw_document_numbers if @raw_document_numbers

    doc_numbers = []

    table_of_contents_data["agencies"].each do |agency|
      agency["document_categories"].each do |doc_cat|
        doc_cat["documents"].each do |doc|
          doc_numbers << doc["document_numbers"]
        end
      end
    end

    @document_numbers = doc_numbers.flatten
  end

  def filtered_document_numbers
    @filtered_document_numbers ||= filter_to_documents.map(&:document_number)
  end

  def raw_agencies
    @raw_agencies ||= table_of_contents_data["agencies"].inject({}) do |hsh, agency_hash|
      hsh[agency_hash['slug']] = TableOfContentsPresenter::Agency.new(agency_hash, self)
      hsh
    end
  end

  def filtered_agencies
    filtered_agencies = {}

    if filter_to_documents
      raw_agencies.each do |key, agency|
        if agency.see_also && agency.document_categories.empty?
          if agency.see_also.any?{|sa| filtered_agency_slugs.include?(sa["slug"])}
            filtered_see_also = agency.see_also.select do |agency_representation|
              filtered_agency_slugs.include?(agency_representation["slug"])
            end
            agency.see_also = filtered_see_also
            filtered_agencies[key] = agency
          end
        end

        if filtered_agency_slugs.include?(agency.slug)
          filtered_doc_cats = agency.document_categories.select do |cat|
            filtered_docs = cat["documents"].select do |doc|
              doc["document_numbers"].any?{|document_number| filtered_document_numbers.include?(document_number)}
            end

            if filtered_docs.present?
              cat["documents"] = filtered_docs
            else
              false
            end
          end

          if filtered_doc_cats.present?
            agency.document_categories = filtered_doc_cats
            filtered_agencies[key] = agency
          end
        end
      end
    end

    filtered_agencies
  end
end
