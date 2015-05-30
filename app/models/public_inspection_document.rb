class PublicInspectionDocument < FederalRegister::PublicInspectionDocument
  def excluding_parent_agencies
    # Public Inspection Documents only get a parent agency associated when
    # it is a co-publication between the parent and child agencies, so the
    # parent agency should never be excluded
    agencies
  end
end
