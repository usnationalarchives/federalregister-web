class TopicDecorator < ApplicationDecorator
  delegate_all
  def initialize(topic)
    super(topic)
  end
end
