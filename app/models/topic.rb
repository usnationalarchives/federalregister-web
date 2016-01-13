class Topic < FederalRegister::Topic
  def self.suggestions(term)
    args = {
      conditions: {
        term: term
      },
      fields: [:name, :slug, :url]
    }

    topics = super(args)

    topics.map{|topic|
      TopicDecorator.decorate(topic)
    }
  end
end
