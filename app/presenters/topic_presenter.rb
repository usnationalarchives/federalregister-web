class TopicPresenter
  attr_reader :topic

  delegate :documents,
    :name,
    :search_conditions,
    :slug,
    :total_document_count, to: :@topic

  def initialize(slug)
    @topic = Topic.search.detect{|topic| topic.slug == slug}

    raise ActiveRecord::RecordNotFound unless @topic
  end

  def search_header
    content_tag(:p, class: 'search_count') do
      "Showing 1-#{documents.count} of" +
      link_to(
        pluralize(total_document_count, 'result'),
        documents_search_path(topic.search_conditions)
      ) +
      ""
    end.html_safe
  end
end
