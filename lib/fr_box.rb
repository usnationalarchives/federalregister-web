class FrBox
  def self.build(type, options={})
    "FrBox::#{type.to_s.camelize}".constantize.new(options)
  end
end
