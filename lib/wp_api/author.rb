class WpApi::Author
  attr_reader :attributes

  def self.find(id)
    all.select{|c| c.id == id}.first
  end

  def self.all
    @all ||= WpApi::Client.get_users
  end

  def initialize(attributes)
    @attributes = validate_attributes(attributes)
  end

  WHITELISTED_ATTRIBUTES = [
    'avatar_urls',
    'description',
    'id',
    'link',
    'name',
    'slug',
  ]

  WHITELISTED_ATTRIBUTES.each do |attribute|
    define_method(attribute.downcase) { attributes[attribute] }
  end

  private

  def validate_attributes(attributes)
    attributes.is_a?(Hash) ? attributes : {}
  end
end
