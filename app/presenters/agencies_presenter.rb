class AgenciesPresenter
  attr_reader :agencies,
    :agency,
    :public_inspection_documents

  def initialize(agencies, agency_identifier)
    @agencies = agencies
    @agency = get_agency(agency_identifier)
  end

  def get_agency(identifier)
    AgencyDecorator.
      new(
        agencies.
          detect{|a| a.url.split('/').last == identifier},
        agencies
      )
  end

  def documents
    @documents ||= FederalRegister::Article.search(
      conditions: {
        agency_ids: [@agency.id]
      },
      order: 'newest',
      per_page: 40
    ).map{|document| DocumentDecorator.decorate(document)}
  end

  def significant_documents
    @significant_documents ||= FederalRegister::Article.search(
      conditions: {
        agency_ids: [@agency.id],
        significant: '1',
        publication_date: {
          gte: 3.months.ago.to_date.to_s
        }
      },
      order: 'newest',
      per_page: 40
    ).map{|document| DocumentDecorator.decorate(document)}
  end


  def public_inspection_documents
    @public_inspection_documents ||= FederalRegister::PublicInspectionDocument.search(
      conditions: {
        agency_ids: [agency.id]
      },
      per_page: 250,
      order: 'newest',
    ).map{|document| DocumentDecorator.decorate(document)}
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
