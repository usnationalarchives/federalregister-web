class TopicFacet < FederalRegister::Facet::Topic
  def total_document_count
    @document_count ||= ::Document.search(
        search_conditions.deep_merge!(
          metadata_only: 1
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
        topics: Array(slug)
      },
      order: 'newest'
    )
  end

  def per_page
    20
  end
end
