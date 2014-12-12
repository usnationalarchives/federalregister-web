class Topic
  attr_reader :name, :identifier, :count
  def initialize(identifier, data)
    @name = data["name"]
    @identifier = identifier
    @count = data["count"]
  end

  def request
    @request ||= HTTParty.get(
      "https://www.federalregister.gov/api/v1/articles?conditions[topics][]=#{identifier}"
    )
  end

  def documents
    @documents ||= request["results"].map do |result|
      DocumentDecorator.decorate(FederalRegister::Article.new(result))
    end
  end
end
