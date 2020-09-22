class PublicInspectionDocument < FederalRegister::PublicInspectionDocument

  add_attribute :page_views

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

  def page_views
    if attributes["page_views"]
      last_updated = begin
        DateTime.parse(attributes["page_views"]["last_updated"])
      rescue
        nil
      end

      {
        count: attributes["page_views"]["count"],
        last_updated: last_updated
      }
    end
  end

end
