class HtmlCompilator::Tables::Cell
  delegate :h, :to => :table

  def to_html
    h.content_tag(element, body, html_attributes)
  end

  def body
    table.transform(node.to_xml)
  end

  def css_classes
    [
      alignment
    ] + border_classes
  end

  def html_attributes
    {}.tap do |attributes|
      attributes[:colspan] = colspan if colspan > 1
      attributes[:rowspan] = rowspan if rowspan > 1
      attributes[:class] = css_classes.join(" ")
    end
  end

  def border_classes
    @border_classes ||= [].tap do |classes|
      classes << "border-top-#{border_top}" if border_top
      classes << "border-bottom-#{border_bottom}" if border_bottom
      classes << "border-left-#{border_left}" if border_left
      classes << "border-right-#{border_right}" if border_right
    end
  end

  def start_column
    table.columns[start_column_index]
  end

  def start_column_index
    if previous_cell_in_row.nil?
      0
    else
      previous_cell_in_row.end_column_index + 1
    end
  end

  def previous_cell_in_row
    if index == 0
      nil
    else
      row.all_cells[index-1]
    end
  end

  def end_column
    if end_column_index >= table.columns.size
      table.columns.last
    else
      table.columns[end_column_index]
    end
  end

  def end_column_index
    start_column_index + colspan - 1
  end

  def last_cell_in_row?
    end_column_index + 1 >= table.num_columns
  end
end
