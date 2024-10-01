class FrSearchSuggestion < OpenStruct
  attr_reader :type

  def kind
    :total_search_results
  end

  def row_classes
    ["suggestion"]
  end

  def removed
    false
  end

  def search_suggestion?
    true
  end

  def toc_suffix
    nil
  end

  def usable_highlight
    false
  end

  def method_missing(method_name, *args, &block)
    # ie raise error for unexpected method calls
    if @table.key?(method_name.to_sym) || @table.key?(method_name.to_s.chomp('=').to_sym)
      super
    else
      raise NoMethodError, "undefined method `#{method_name}` for #{self}"
    end
  end

end
