class HtmlCompilator::Tables::Column
  def self.generate(options)
    table = options.fetch(:table)
    table.node.attr('CDEF').split(/\s*,\s*/).map do |code|
      new(:table => table, :code => code)
    end
  end

  attr_reader :table, :code

  def initialize(options)
    @table = options.fetch(:table)
    @code = options.fetch(:code)
  end

  def alignment
    if figure?
      :right
    else
      :center
    end
  end

  def figure?
    code =~ /^\d/
  end
end
