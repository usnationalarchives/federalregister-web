class FrIndexAgencyPresenter #TODO: Refactor public/private interfaces
  attr_reader :year, :agency_slug, :document_index

  def initialize(year, agency_slug)
    @year = year.to_i
    @agency_slug = agency_slug
    @document_index = HTTParty.get(url)

    raise ActiveRecord::RecordNotFound if @document_index.code == 404
  end

  class DocumentTypeRepresentation
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
      granule_class = DocumentType.new(category["type"]).granule_class
      DocumentTypeRepresentation.new(
        name: category["type"],
        granule_class: granule_class,
        anchor_link: "##{agency_slug}-#{category["type"]}".downcase.gsub(' ','-'),
        document_count: document_type_counts[granule_class],
        subject_count: category["documents"].group_by{|d|d["subject_1"]}.keys.size,
      )
    end
  end

  def agency_name
    document_index["name"]
  end

  def total_document_count
    @total_count ||= document_type_counts.inject(0) do |sum, (type, count)|
      sum += count
      sum
    end
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
    "#{Settings.federal_register.base_uri}/fr_index/#{year}/#{agency_slug}.json"
  end

  def document_partial
    'indexes/doc_details'
  end

  def name
    "#{year} Federal Register Index"
  end

  def description
    "This index provides descriptive entries and Federal Register page numbers for documents published by #{agency_name} in the daily Federal Register. It includes entries, with select metadata for all documents published in the #{year} calendar year."
  end

  def fr_content_box_type
    :reader_aid
  end

  def agency
    @agency ||= {agency_slug => TableOfContentsPresenter::Agency.new(document_index, self) }
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
