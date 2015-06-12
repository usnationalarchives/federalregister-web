class TopicPresenter
  attr_reader :topic_identifier
  def initialize(topic_identifier)
    @topic_identifier = topic_identifier
  end

  def topic
    @topic ||= topics.detect{|topic| topic.identifier == topic_identifier}
  end

  def invalid_topic?
    topic.blank? || topic.request.response.code != "200"
  end

  def metadata
    @metadata ||= HTTParty.get(
      "https://www.federalregister.gov/api/v1/articles.json?metadata_only=1&conditions[topics]=#{topic_identifier}"
    )
  end

  def result_count_text
    @search_count ||= "#{metadata["count"]} results"
  end

  def more_results_count_text
    "See #{metadata["count"] - topic.documents.count} more results"
  end

  def topic_search_conditions
    {:conditions => {:topics => topic_identifier}}
  end
end
