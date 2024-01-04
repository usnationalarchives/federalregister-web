class EoCollectionFacet
  attr_reader :president, :type

  def initialize(president, type)
    @president = president
    @type = type
  end

  def facet
    @counts ||= "FederalRegister::Facet::Document::#{type.capitalize}".constantize.search(
      QueryConditions::PresidentialDocumentConditions.all_presidential_documents_for(
        president, 'executive_order'
      ).deep_merge!({
        conditions: {correction: 0},
        include_pre_1994_docs: true
      })
    ).results.map do |facet|
      EoFacet.new(
        count: facet.count,
        year: facet.name.to_i,
        slug: facet.slug
      )
    end
  end

  class EoFacet
    vattr_initialize [
      :count,
      :slug,
      :year
    ]
  end
end
