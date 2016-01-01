class FrIndexPresenter
  attr_reader :year, :index

  def initialize(year)
    raise ActiveRecord::RecordNotFound if year.to_i < 2013
    @year = year.to_i
    @index = HTTParty.get(index_json_url)
  end

  class AgencyRepresentation
    vattr_initialize [
      :name,
      :slug,
      :count,
      :see_also_references
    ]
  end

  def agency_representations
    @agency_representations ||= index["agencies"].map do |agency|
      if agency["slug"].present?
        AgencyRepresentation.new(
          name: agency["name"],
          slug: agency["slug"],
          count: agency_slug_facet_mappings[agency["slug"]],
          see_also_references: process_see_also(agency["see_also"])
        )
      else
        AgencyRepresentation.new(
          name: agency["name"],
          slug: agency["slug"],
          count: 0,
          see_also_references: [
            AgencyRepresentation.new(
              name: agency["see_also"].first["name"],
              slug: agency["see_also"].first["slug"],
              count: 0
            )
          ]
        )
      end
    end
  end

  def agency_representations_by_first_letter
    @agency_representations_by_first_letter ||=
      Hash[ agency_representations.group_by{|a|a.name[0]}.sort_by{|k,v|k} ]
  end

  def index_json_url
    "#{Settings.federal_register.base_uri}/fr_index/#{year}/index.json"
  end

  def date_last_issue_published
    DocumentIssue.last_issue_published(year)
  end

  def available_years
    min_year = 2013
    (min_year..Date.today.year).to_a.reverse
  end

  def name
    "#{year} Federal Register Index"
  end

  def description
    "This index provides descriptive entries and Federal Register page numbers for documents published in the daily Federal Register. It includes entries, with select metadata for all documents published in the #{year} calendar year."
  end

  def fr_content_box_type
    :reader_aid
  end

  private

  def process_see_also(child_agencies)
    return [] if child_agencies.nil?
    child_agencies.map do |child_agency|
      AgencyRepresentation.new(
        name: child_agency["name"],
        slug: child_agency["slug"],
        count: agency_slug_facet_mappings[child_agency["slug"]],
      )
    end
  end

  def agency_slug_facet_mappings
    @agency_slug_facet_mappings ||= agency_facets.inject({}) do |hsh,facet|
      hsh[facet.slug] = facet.count
      hsh
    end
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
