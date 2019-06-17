class TableOfContentsPresenter
  attr_reader :table_of_contents_data, :date, :filter_to_documents

  def initialize(date, filter_to_documents=nil)
    @date = date.is_a?(Date) ? date : Date.parse(date)
    @table_of_contents_data = retrieve_toc_data
    @filter_to_documents = filter_to_documents
  end

  def retrieve_toc_data
    response = HTTParty.get(url)

    raise ActiveRecord::RecordNotFound if response.code == 404
    response
  end

  def url
    "#{Settings.federal_register.internal_base_url}/document_issues/json/#{date.to_s(:ymd)}.json"
  end

  def document_partial
    'document_issues/document_details'
  end

  def agencies
    filter_to_documents.present? ? filtered_agencies : raw_agencies
  end

  def document_numbers
    filtering_documents? ? filtered_document_numbers : raw_document_numbers
  end

  def filtering_documents?
    filter_to_documents.present?
  end

  def documents
    retrieve_documents.map{|d| DocumentDecorator.decorate(d)}
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
    return @documents if @documents

    documents = Document.search(
      QueryConditions.published_on(date).deep_merge(
        per_page: 1000,
        fields: document_fields
      )
    ).results

    if filtering_documents?
      @documents = documents.select{|d| document_numbers.include?(d.document_number)}
    else
      @documents = documents
    end
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
      agency_representation = TableOfContentsPresenter::Agency.new(agency_hash, self)
      hsh[agency_representation.slug] = agency_representation
      hsh
    end
  end

  # filter the toc down to agencies that match (and their parent see references)
  def filtered_agencies
    filtered_toc = {}

    raw_agencies.each do |key, agency|
      if agency.see_also && agency.document_categories.empty?
        selected_agency = select_agency_with_see_also_reference_to(agency)
        filtered_toc[key] = selected_agency if selected_agency
      end

      if toc_agencies_matching_filtered_documents.include?(agency)
        filtered_document_categories = filter_document_categories(agency)

        if filtered_document_categories.present?
          agency.document_categories = filtered_document_categories
          filtered_toc[key] = agency
        end
      end
    end

    filtered_toc
  end

  def toc_agencies_matching_filtered_documents
    return @matching_agencies if @matching_agencies

    @matching_agencies = []

    raw_agencies.each do |key, agency|
      @matching_agencies << agency if filter_document_categories(agency).present?
    end

    @matching_agencies
  end

  def select_agency_with_see_also_reference_to(agency)
    if agency.see_also.any?{|sa|
      toc_agencies_matching_filtered_documents.any?{|a| a.slug == sa["slug"]}
    }
      agency.see_also = filter_see_also(agency)
      agency
    end
  end

  def filter_see_also(agency)
    agency.see_also.select do |agency_representation|
      toc_agencies_matching_filtered_documents.any?{|a| a.slug == agency_representation["slug"]}
    end
  end

  def filter_document_categories(agency)
    agency.document_categories.select do |category|
      filtered_docs = category["documents"].select do |doc|
        doc["document_numbers"].any?{|document_number| filtered_document_numbers.include?(document_number)}
      end

      if filtered_docs.present?
        category["documents"] = filtered_docs
      else
        false
      end
    end
  end
end
