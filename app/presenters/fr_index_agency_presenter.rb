class FrIndexAgencyPresenter
  attr_reader :year, :agency_slug, :document_index

  def initialize(year, agency_slug)
    @year = year.to_i
    @agency_slug = agency_slug
    @document_index = HTTParty.get(url)
    raise ActiveRecord::RecordNotFound if @document_index.code == 404
  end


  def document_type_slugs #TODO: Locate definitive place for this info.
    {
      "Proposed Rules"=>"PRORULE",
      "Rules"=>"RULE",
      "Presidential Documents"=>"PRESDOCU",
      "Notices"=>"NOTICE",
      "Corrections"=>"CORRECT",
      "Sunshines"=>"SUNSHINE",
      "Unknown"=>"UNKNOWN"
    }
  end

  class DocumentType
    vattr_initialize [
      :name,
      :slug,
      :document_count,
      :anchor_link,
      :subject_count,
    ]
  end

  def document_types
    return nil if document_index["document_categories"].nil?
    document_index["document_categories"].map do |category|
      slug = document_type_slugs[category["name"]]
      DocumentType.new(
        name: category["name"],
        slug: slug,
        anchor_link: "##{agency_slug}-#{category["name"]}".downcase.gsub(' ','-'),
        document_count: document_type_counts[slug],
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
      ).
      inject({}) do |hsh, facet|
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

  class Agency < TableOfContentsPresenter::Agency #TODO: Move TableOfContentsPresenter::Agency into
    #higher class to maximize re-use.
  end

  def agency
    @agency ||= {agency_slug => Agency.new(document_index, self) }
  end

  def documents
    return @documents if @documents
    results = Document.search(
      {
        conditions: {
          publication_date: {
            gte: Date.new(year,1,1).to_s(:iso),
            lte: Date.new(year,12,31).to_s(:iso)
          },
          agencies: agency_slug
        },
        per_page: 1000,
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
    )

    all_documents = []
    loop do
      results.each {|d| all_documents << DocumentDecorator.decorate(d)}
      break if results.next == nil
      results = results.next
    end
    @documents = all_documents
  end


end
