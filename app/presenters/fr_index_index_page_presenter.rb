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
        if hsh[id_to_slug(agency.parent_id)].nil?
          hsh[id_to_slug(agency.parent_id)] = [id_to_slug(agency.id)]
        else
          hsh[id_to_slug(agency.parent_id)] << id_to_slug(agency.id)
        end
      end
    end
    hsh
  end

  class AgencyRepresentation
    vattr_initialize [
      :name,
      :count,
      :see_also_references
    ]
  end

  def agency_representations_by_first_letter
    Hash[ agency_representations.group_by{|a|a.name[0]}.sort_by{|k,v|k} ]
  end

  def agency_representations
    agency_facets.map do |agency_facet|
      AgencyRepresentation.new(
        name: agency_facet.name,
        count: agency_facet.count,
        see_also_references: see_also_processor(agency_facet.slug)
      )
    end
  end

  def see_also_processor(slug)
    child_agency_slugs = see_also_references[slug]
    return [] if child_agency_slugs.nil?
    results = []
    child_agency_slugs.each do |child_agency_slug|
      agency = agency_facets.find{|agency_facet|agency_facet.slug == child_agency_slug}
      if agency && agency.count > 0
        results << OpenStruct.new(name: agency.name, count: agency.count)
      end
    end
    results
  end

  def id_to_slug(agency_id)
    agencies.find{|agency|agency.id == agency_id}.slug
  end

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
