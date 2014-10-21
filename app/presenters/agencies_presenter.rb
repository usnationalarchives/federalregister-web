class AgenciesPresenter
  attr_reader :agencies, :agency
  def initialize(agencies)
    @agencies = agencies
  end

  def agency(slug)
    AgencyDecorator.
      new(
        agencies.
          detect{|agency| agency.url.split('/').last == slug},
        agencies
      )
  end

  def parent_agencies
    agencies.
      select{|agency| agency.parent_id.blank?}.
      map{|agency| AgencyDecorator.decorate(agency)}
  end

  def children_of(parent_agency)
    agencies.
      select{|agency| agency.parent_id == parent_agency.id}.
      map{|agency| AgencyDecorator.decorate(agency)}
  end
end
