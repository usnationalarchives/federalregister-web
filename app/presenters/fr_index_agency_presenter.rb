class FrIndexAgencyPresenter
  attr_reader :year, :agency_slug, :document_index

  def initialize(year, agency_slug)
    @year = year.to_i
    @agency_slug = agency_slug
    @document_index = HTTParty.get(url)
  end

  class DocumentType
    vattr_initialize [
      :name,
      :type,
      :document_count,
      :subject_count
    ]
  end

  def document_type_names #TODO: Locate definitive place for this info.
    {
      "NOTICE" => "Notice",
      "PRESDOCU" => "Presidential Document",
      "PRORULE" => "Proposed Rule",
      "RULE" => "Rule",
      "UNKNOWN" => "Unknown",
    }
  end

  def document_types
    document_index["document_categories"].map do |category|
      DocumentType.new(
        name: document_type_names[category["name"]], #TODO: Change source data to definitive location
        type: category["name"],
        document_count: document_type_counts[category["name"]],
        subject_count: category["documents"].group_by{|d|d["subject_1"]}.keys.size,
      )
    end
  end

  def agency_name
    document_index["name"]
  end

  def total_document_count
    total=0
    @total_count ||= document_type_counts.each do |type, count|
      total+=count
    end
    total
  end

  def document_type_counts
    @document_type_counts ||= DocumentTypeFacet.
      search(
        conditions: {
          publication_date: {
            gte: Date.new(year,1,1).to_s(:iso),
            lte: Date.new(year,12,31).to_s(:iso)
          },
          agencies: [agency_slug]
        }
      ).inject({}) do |hsh, facet|
          hsh[facet.slug]= facet.count
          hsh
        end
  end

  def doc_counts_by_category
    hsh = {}
    document_index["document_categories"].each do |category|
      hsh[category["name"]] = category["documents"].group_by{|d|d["subject_1"]}.keys.size
    end
    hsh
  end

  def url
    "#{Settings.federal_register.base_uri}/index/#{year}/#{agency_slug}.json"
  end

  def document_partial
    'indexes/doc_details'
  end

  def agency
    @agency ||= {agency_slug => Agency.new(document_index, self) }
  end

  def documents
    @documents ||= Document.search(
      {
        conditions: {
          publication_date: {
            gte: Date.new(year,1,1).to_s(:iso),
            lte: Date.new(year,12,31).to_s(:iso)
          },
          agencies: agency_slug
        },
        per_page: 1000, #TODO: This could present an issue for longer time periods.
        fields: [
          :document_number,
          :start_page,
          :end_page,
          :html_url,
          :publication_date,
          :significant,
          :title,
          :pdf_url,
          :regulations_dot_gov_info
        ]
      }
    ).results.map{|d| DocumentDecorator.decorate(d)}
  end



  # reload!;FrIndexAgencyPresenter.new(2014,"treasury-department").document_type_counts

  class Agency < TableOfContentsPresenter::Agency #TODO: Move TableOfContentsPresenter::Agency into
    #higher class to maximize re-use.
  end

end
