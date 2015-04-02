class HtmlCompilator::Tables::BodyCell
  attr_reader :row, :node
  delegate :expanded_stub_width, :to => :row

  def initialize(options)
    @row = options.fetch(:row)
    @node = options.fetch(:node)
  end

  def body
    node.text
  end

  def colspan
    if stub? && (expanded_stub_width > 0)
      1 + expanded_stub_width
    elsif node.attr("I") == "28" # "centerhead accross entire table"
      row.table.num_columns
    elsif node.attr("A")
      1 + node.attr("A").sub(/^[LRJ]/,'').to_i
    else
      1
    end
  end

  def rowspan
    1
  end

  def stub?
    index == 0
  end

  def index
    @index ||= row.cells.index(self)
  end
end
