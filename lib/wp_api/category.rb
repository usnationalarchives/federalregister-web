class WpApi::Category
  attr_reader :attributes

  def self.find(id)
    all.select{|c| c.id == id}.first
  end

  def self.all
    @all ||= WpApi::Client.get_categories
  end

  def initialize(attributes)
    @attributes = validate_attributes(attributes)
  end

  WHITELISTED_ATTRIBUTES = [
    'id',
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
