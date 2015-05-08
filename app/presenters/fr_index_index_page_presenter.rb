require 'ostruct'

class FrIndexIndexPagePresenter
  attr_reader :year

  def initialize(year)
    @year = year.to_i
  end

  def see_also_references
    hsh = {}
    agencies.each do |agency|
      if agency.parent_id.present?
        if hsh[id_to_slug_improved(agency.parent_id)].nil?
          hsh[id_to_slug_improved(agency.parent_id)] = [id_to_slug_improved(agency.id)]
        else
          hsh[id_to_slug_improved(agency.parent_id)] << id_to_slug_improved(agency.id)
        end
      end
    end
    hsh
  end

  class AgencyRepresentation
    vattr_initialize [
      :name,
      :slug,
      :count,
      :see_also_references
    ]
  end

  def agency_representations_by_first_letter
    @agency_representations_by_first_letter ||=
      Hash[ agency_representations.group_by{|a|a.name[0]}.sort_by{|k,v|k} ]
  end

  def agency_representations
    @agency_representations ||= agency_facets.map do |agency_facet|
      AgencyRepresentation.new(
        name: agency_facet.name,
        slug: agency_facet.slug,
        count: agency_facet.count,
        see_also_references: see_also_processor(agency_facet.slug)
      )
    end.sort_by{|agency_representation|agency_representation.name}
  end

  def see_also_processor(slug)
    child_agency_slugs = see_also_references[slug]
    return [] if child_agency_slugs.nil?
    results = []
    child_agency_slugs.each do |child_agency_slug|
      agency_facet = agency_facets.find{|agency_facet|agency_facet.slug == child_agency_slug}
      if agency_facet && agency_facet.count > 0
        results << OpenStruct.new(name: agency_facet.name,
                                  slug: agency_facet.slug,
                                  count: agency_facet.count)
      end
    end
    results
  end

  def id_to_slug_improved(agency_id)
    agency_slug_id_mappings[agency_id]
  end

  def agency_slug_id_mappings
    @agency_slug_id_mappings ||= agencies.inject({}) do |hsh,agency|
      hsh[agency.id] = agency.slug
      hsh
    end
  end


  private

  def agencies
    @agencies ||= FederalRegister::Agency.all
  end

  def agency_facets
    @agency_facets ||= AgencyFacet.search(
      {
        conditions: {
          publication_date: {
            gte: Date.new(year,1,1).to_s(:iso),
            lte: Date.new(year,12,31).to_s(:iso)
          }
        },
        per_page: 1000
      }
    )
  end

end
