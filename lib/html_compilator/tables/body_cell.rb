class HtmlCompilator::Tables::BodyCell < HtmlCompilator::Tables::Cell
  extend Memoist

  # key is the ENT I attribute value
  # the first value is how much to ident
  # the second value is whether it should be a hanging indent
  INDENTATION_RULES = {
     1 => [0, true],
     2 => [1, true],
     3 => [2, true],
     4 => [3, true],
     5 => [4, true],
     6 => [5, true],
     7 => [6, true],
     8 => [7, true],
     9 => [8, true],
    10 => [9, true],
    11 => [0, true],
    12 => [1, true],
    13 => [2, true],
    14 => [3, true],
    15 => [4, true],
    16 => [5, true],
    17 => [6, true],
    18 => [7, true],
    19 => [8, true],
    20 => [9, true],
    22 => [0, true],
    24 => [1, false],
    25 => [0, false],
    26 => [0, true],
    27 => [0, false],
    29 => [1, false],
    31 => [0, true],
    38 => [0, true],
    50 => [0, false],
  }
  attr_reader :row, :node, :index, :start_column_index
  delegate :expanded_stub_width, :table, :to => :row
  delegate :h, :to => :table

  def initialize(options)
    @row = options.fetch(:row)
    @node = options.fetch(:node)
    @index = options.fetch(:index)
    @start_column_index = options.fetch(:start_column_index)
  end

  def element
    :td
  end

  def css_classes
    super + stub_classes
  end

  def stub_classes
    if stub? || override_indentation
      if primary_indentation && primary_indentation > 0
        if hanging_indentation
          ["primary-indent-hanging-#{primary_indentation}"]
        else
          ["primary-indent-#{primary_indentation}"]
        end
      else
        []
      end
    else
      []
    end
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
    if end_column.border_right
      end_column.border_right
    else
      if last_cell_in_row?
        table.rules.include?(:side) ? :single : nil
      else
        table.rules.include?(:down) ? :single : nil
      end
    end
  end

  def primary_indentation
    return override_indentation if override_indentation

    cell_i = node.attr("I").to_i
    INDENTATION_RULES[cell_i].try(:first)
  end

  OVERRIDE_INDENTATION = /i(?<indentation>\d+)/

  def override_indentation
    if (match = OVERRIDE_INDENTATION.match(node.attr("O")))
      match[:indentation].to_i
    end
  end
  memoize :override_indentation

  def hanging_indentation
    cell_i = node.attr("I").to_i
    INDENTATION_RULES[cell_i].try(:last)
  end

  def stub?
    # ask the column if it is a stub?
    index == 0
  end
end
