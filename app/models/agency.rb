class Agency < FederalRegister::Agency
  def total_document_count
    @document_count ||= ::Document.search(
        search_conditions.deep_merge!(
          metadata_only: true
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
        search_conditions.deep_merge!(
          metadata_only: true
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
        search_conditions.deep_merge!(
          conditions: {
            significant: 1
          },
          metadata_only: true
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
        agencies: slug
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
    return [] unless child_ids.present?

    @children ||= Agency.find(child_ids.join(','), fields.present? ? {fields: fields} : {})
  end
end
