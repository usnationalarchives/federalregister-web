class AgencyFacetDecorator < FacetDecorator
  def url
    h.agency_path(slug)
  end
end
