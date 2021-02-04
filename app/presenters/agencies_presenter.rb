class AgenciesPresenter
  attr_reader :agencies, :child_agencies
  extend Memoist

  delegate :count, to: :@agencies

  def initialize
    @agencies = FederalRegister::Agency.all(
      fields: ['id', 'name', 'parent_id', 'url', 'slug']
    ).select{|agency| agencies_with_documents[agency.slug] }
    @child_agencies = {}
  end

  def parent_agencies
    @parent_agencies ||= agencies.
      select{|agency| agency.parent_id.blank?}
  end

  def children_of(parent_agency)
    return @child_agencies[parent_agency.id] if @child_agencies[parent_agency.id]

    @child_agencies[parent_agency.id]= agencies.
      select{|agency| agency.parent_id == parent_agency.id}
  end

  private

  def agencies_with_documents
    FederalRegister::Facet::Agency.search.each_with_object(Hash.new) do |facet, hsh|
      hsh[facet.slug] = true
    end
  end
  memoize :agencies_with_documents
end
