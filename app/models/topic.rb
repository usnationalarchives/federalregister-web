class Topic < FederalRegister::Facet::Topic
  def self.search(conditions={})
    super(conditions)
  end

  def total_document_count
    @document_count ||= FederalRegister::Document.search(
        search_conditions.deep_merge!(
          metadata_only: true
        )
      ).count
  end

  def documents
    @documents ||= FederalRegister::Document.search(
        search_conditions.deep_merge!(
          per_page: 50
        )
      ).map{ |document|
        DocumentDecorator.decorate(document)
      }
  end

  def search_conditions
    result_set.conditions.deep_merge(
      conditions: {
        topics: slug
      }
    )
  end
end
