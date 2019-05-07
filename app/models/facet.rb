class Facet
  attr_reader :value, :name, :condition, :count

  def initialize(options)
    @value      = options[:value]
    @name       = options[:name]
    @condition  = options[:condition]
    @count      = options[:count]
  end
end

