#NOTE: Ruby 3 deprecates URI.escape and URI.encode (aliased method), which is called from the federal_register gem.  This monkey patches the federal_register gem calls to use Addressable as a stand-in until the gem is updated.

module URI
  def self.escape(*args)
    Addressable::URI.escape(*args)
  end

  def self.encode(*args)
    Addressable::URI.escape(*args)
  end

end
