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
      :left
    end
  end

  def figure?
    code =~ /^\d/
  end

  def border_right
    nil
  end

  def index
    table.columns.index(self)
  end

  def first?
    index == 0
  end

  def last?
    index + 1 == table.columns.size
  end
end
