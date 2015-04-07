class HtmlCompilator::Tables::BodyCell < HtmlCompilator::Tables::Cell
  attr_reader :row, :node
  delegate :expanded_stub_width, :table, :to => :row
  delegate :h, :to => :table

  def initialize(options)
    @row = options.fetch(:row)
    @node = options.fetch(:node)
  end

  def element
    :td
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
    case node.attr('I')
    when '21','25','28'
      :center
    else
      if node.attr("A")
        case node.attr("A").match(/^(\D)/).try(:[], 1)
        when 'R'
          :right
        when 'L'
          :left
        when 'J'
          :justify
        when nil
          :center
        end
      else
        start_column.alignment
      end
    end
  end

  def border_top
  end

  def border_bottom
    if table.rules.include?(:horizonal) && row.last?
      :single
    else
      row.border_bottom_for_index(start_column_index)
    end
  end

  def border_left
    if start_column.first?
      table.rules.include?(:side) ? :single : nil
    end
  end

  def border_right
    if last_cell_in_row?
      table.rules.include?(:side) ? :single : nil
    else
      table.rules.include?(:down) ? :single : nil
    end
  end

  def stub?
    # ask the column if it is a stub?
    index == 0
  end

  def index
    @index ||= row.cells.index(self)
  end

  def start_column_index
    if previous_cell_in_row.nil?
      0
    else
      previous_cell_in_row.end_column_index + 1
    end
  end
end
