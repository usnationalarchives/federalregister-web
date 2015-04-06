class HtmlCompilator::Tables::BodyCell
  attr_reader :row, :node
  delegate :expanded_stub_width, :table, :to => :row
  delegate :h, :to => :table

  def initialize(options)
    @row = options.fetch(:row)
    @node = options.fetch(:node)
  end

  def to_html
    h.content_tag(:td, body, td_attributes)
  end

  def td_attributes
    {}.tap do |attributes|
      attributes[:colspan] = colspan if colspan > 1
      attributes[:class] = css_classes.join(" ")
    end
  end

  def css_classes
    [
      alignment
    ]
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

  def alignment
    case (node.attr("A") || '').match(/^(\D)/).try(:[], 1)
    when 'R'
      :right
    when 'L'
      :left
    when 'J'
      :justify
    when nil
      column.alignment
    end
  end

  def stub?
    # ask the column if it is a stub?
    index == 0
  end

  def index
    @index ||= row.cells.index(self)
  end

  def column
    table.columns[start_column_index]
  end

  def start_column_index
    if previous_cell.nil?
      0
    else
      previous_cell.end_column_index + 1
    end
  end

  def end_column_index
    start_column_index + colspan - 1
  end

  def previous_cell
    if index == 0
      nil
    else
      row.cells[index-1]
    end
  end
end
