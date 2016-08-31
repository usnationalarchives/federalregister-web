class ListOfSubjectsTopicParser
  SPECIAL_CASE_TOPICS = {
    # Guantanamo Bay Naval Station, Cuba
    "Cuba" => "Guantanamo Bay Naval Station"
  }

  def self.parse(topic_string)
    topics = []

    return topics unless topic_string.present?

    previous_topic = nil
    topic_string.split(',').each do |current_topic|
      current_topic = current_topic.strip.gsub('.', '')
      if /[[:upper:]]/.match(current_topic.split.first)
        if special_case?(current_topic)
          if previous_topic == previous_topic_for_special_case(current_topic)
            previous_topic = [previous_topic, current_topic].join(', ')
          end
        else
          if previous_topic
            topics << previous_topic
          end
          previous_topic = current_topic
        end
      else
        previous_topic = [previous_topic, current_topic].join(', ')
      end
    end
    topics << previous_topic
    topics
  end

  private

  def self.special_case?(topic)
    SPECIAL_CASE_TOPICS.keys.include?(topic)
  end

  def self.previous_topic_for_special_case(topic)
    SPECIAL_CASE_TOPICS[topic]
  end
end
