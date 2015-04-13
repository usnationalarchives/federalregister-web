class HtmlCompilator::Tables::Column
  def self.generate(options)
    table = options.fetch(:table)
    table.node.attr('CDEF').split(/\s*,\s*/).map do |code|
      new(:table => table, :code => code)
    end
  end

  attr_reader :table, :code
  delegate :h, to: :table

  def initialize(options)
    @table = options.fetch(:table)
    @code = options.fetch(:code)
  end

  def to_html
    h.tag(:col, style: "width: #{sprintf("%.1f", percentage_width*100)}%")
  end

  def percentage_width
    width_in_points.to_f / table.total_width_in_points
  end

  def width_in_points
    code.gsub(/\D/,'').to_i
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
    case code[-1]
    when 'b'
      :bold
    when 'p'
      :double
    when 'n'
      :none
    end
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
