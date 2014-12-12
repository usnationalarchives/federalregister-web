class Navigation::TopicsPresenter
  # RW: add ids to api endpoint, capitalization?
  ROUTINE_TOPIC_NAMES = [
    "Administrative practice and procedure",
    "Aircraft",
    "Reporting and recordkeeping requirements",
    "Safety"
  ]

  def topics
    @topics ||= HTTParty.get("https://www.federalregister.gov/api/v1/articles/facets/topic").
      map do |identifier, data| 
        unless ROUTINE_TOPIC_NAMES.include?(data["name"])
          TopicDecorator::Nav.decorate(Topic.new(identifier, data))
        end
      end.
      compact.
      sort{|a, b| b.count <=> a.count}.
      slice(0,10).
      sort{|a, b| a.name <=> b.name}
  end
end
