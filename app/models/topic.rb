class Topic < FederalRegister::Facet::Topic
  def self.search(conditions={})
    super(conditions)
  end

  def total_document_count
    @document_count ||= ::Document.search(
        search_conditions.deep_merge!(
          metadata_only: true
        )
      ).count
  end

  def documents
    @documents ||= ::Document.search(
        search_conditions.deep_merge!(
          per_page: per_page
        )
      ).map{|document|
        DocumentDecorator.decorate(document)
      }
  end

  def search_conditions
    result_set.conditions.deep_merge(
      conditions: {
        topics: slug
      },
      order: 'newest'
    )
  end

  def per_page
    20
  end
end
