class TopicFacetDecorator < FacetDecorator
  def url
    h.topic_path(slug)
  end
end
