class TopicDecorator < ApplicationDecorator
  delegate_all

  def url
    h.topic_path(slug)
  end
end
