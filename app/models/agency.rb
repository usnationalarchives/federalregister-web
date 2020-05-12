class Agency < FederalRegister::Agency
  def self.suggestions(term)
    args = {
      conditions: {
        term: term
      },
      fields: [:name, :short_name, :slug, :url]
    }

    agencies = super(args)

    agencies.map{|agency|
      AgencyDecorator.decorate(agency)
    }
  end

  PARTICIPATING_AGENCIES_FILE = 'data/regulations_dot_gov_participating_agencies.csv'

  def self.participating_agency_acronyms
    @participating_agency_ids ||= CSV.new(
      File.open(PARTICIPATING_AGENCIES_FILE),
      :headers => :first_row,
      :skip_blanks => true
    ).map do |row|
      row["Acronym"]
    end
  end

  def total_document_count
    @document_count ||= ::Document.search(
      search_conditions.slice(:conditions).deep_merge!(
        metadata_only: 1
      )
    ).count
  end

  def documents(options={})
    per_page = options.fetch(:per_page) { per_page }

    @documents ||= ::Document.search(
      search_conditions.deep_merge!(
        per_page: per_page
      )
    ).map{|document|
      DocumentDecorator.decorate(document)
    }
  end

  def total_public_inspection_document_count
    @pi_document_count ||= ::PublicInspectionDocument.search(
        search_conditions.slice(:conditions).deep_merge!(
          metadata_only: 1
        )
      ).count
  end

  def public_inspection_documents(options={})
    per_page = options.fetch(:per_page) { per_page }

    @pi_documents ||= ::PublicInspectionDocument.search(
      search_conditions.deep_merge!(
        per_page: per_page
      )
    ).map{|document|
      DocumentDecorator.decorate(document)
    }
  end

  def total_significant_document_count
    @significant_document_count ||= ::Document.search(
        search_conditions.slice(:conditions).deep_merge!(
          conditions: {
            significant: 1
          },
          metadata_only: 1
        )
      ).count
  end

  def significant_documents(options={})
    per_page = options.fetch(:per_page) { per_page }

    @significant_documents ||= ::Document.search(
      search_conditions.deep_merge!(
        conditions: {
          significant: 1
        },
        per_page: per_page
      )
    ).map{|document|
      DocumentDecorator.decorate(document)
    }
  end

  def search_conditions
    {
      conditions: {
        agencies: Array(slug)
      },
      order: 'newest'
    }
  end

  def per_page
    20
  end

  def parent_agency?
    parent_id.present?
  end

  def parent_agency(fields=[])
    return nil unless parent_id

    @parent ||= Agency.find(parent_id, fields.present? ? {fields: fields} : {})
  end

  def child_agencies?
    child_ids.present?
  end

  def child_agencies(fields=[])
    return [] unless child_agencies?

    @children ||= Array(
      Agency.find(child_ids.join(','), fields.present? ? {fields: fields} : {})
    )
  end
end
