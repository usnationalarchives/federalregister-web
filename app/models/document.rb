class Document < FederalRegister::Document

  def self.find(document_number, options={})
    base_query = Hash.new.tap do |hsh|
      publication_date = options[:publication_date]
      if publication_date
        publication_date = publication_date.is_a?(Date) ? publication_date : Date.parse(publication_date)
        hsh[:publication_date] = publication_date.to_s(:iso)
      end
    end

    if options[:fields].present?
      attributes = get(
        "/documents/#{document_number}.json",
        query: base_query.merge({:fields => options[:fields]})
      ).parsed_response
      new(attributes)
    else
      attributes = get(
        "/documents/#{document_number}.json",
        query: base_query
      ).parsed_response
      new(attributes, :full => true)
    end
  end

  def excluding_parent_agencies
    agency_names = agencies.map{|a| a.name}

    if agency_names.any?{|agency_name| agency_name =~ /Office of the Secretary/i}
      agencies
    else
      parent_agency_ids = agencies.map(&:parent_id).compact
      agencies.reject{|a| parent_agency_ids.include?(a.id) }
    end
  end

  def self.search_fields
    [
      :abstract,
      :agencies,
      :document_number,
      :excerpts,
      :html_url,
      :publication_date,
      :title,
      :type,
    ]
  end

  def public_inspection_document
    return @public_inspection_document if @public_inspection_document

    begin
      @public_inspection_document = PublicInspectionDocument.find(
        document_number
      )
    rescue FederalRegister::Client::RecordNotFound
      @public_inspection_document = nil
    end
  end
end
