class DocumentTypeFacet < FederalRegister::Facet::Document::Type
  attr_reader :count, :identifier, :search_parameters

  def initialize(attributes={}, options={}, custom_options = {})
    super(attributes, options)
    @count = custom_options.fetch(:count, 0)
    @identifier = custom_options.fetch(:identifier, nil)
    @search_parameters = custom_options.fetch(:search_parameters, nil)
  end

  def self.search(conditions={})
    super(conditions)
  end

  def search_conditions
    result_set.conditions.deep_merge(
      conditions: {
        type: slug
      }
    )
  end

end
