class PublicInspectionDocument < FederalRegister::PublicInspectionDocument
  def excluding_parent_agencies
    # Public Inspection Documents only get a parent agency associated when
    # it is a co-publication between the parent and child agencies, so the
    # parent agency should never be excluded
    agencies
  end

  def self.search_fields
    [
      :agencies,
      :editorial_note,
      :excerpts,
      :filing_type,
      :html_url,
      :publication_date,
      :title,
      :type,
    ]
  end
end
