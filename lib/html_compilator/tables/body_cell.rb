class HtmlCompilator::Tables::BodyCell
  attr_reader :row, :node
  delegate :expanded_stub_width, :table, :to => :row
  delegate :h, :to => :table

  def initialize(options)
    @row = options.fetch(:row)
    @node = options.fetch(:node)
  end

  def to_html
    h.content_tag(:td, body, :colspan => colspan)
  end

  def body
    row.table.transform(node.to_xml)
  end

  def colspan
    if stub? && (expanded_stub_width > 0)
      1 + expanded_stub_width
    elsif node.attr("I") == "28" # "centerhead accross entire table"
      table.num_columns
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
