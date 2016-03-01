class Document < FederalRegister::Document
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
    @public_inspection_document ||= PublicInspectionDocument.find(
      document_number
    )
  end
end
