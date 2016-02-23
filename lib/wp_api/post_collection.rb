class WpApi::PostCollection < WpApi::Collection
  alias :posts :content

  def initialize(attributes)
    return [] if attributes == ["code", "rest_invalid_param"]
    super attributes
  end

  def model
    WpApi::Post
  end
end
