class HtmlCompilator::Tables::FooterCell
  attr_reader :row, :node
  delegate :table, to: :row

  def initialize(options)
    @row = options.fetch(:row)
    @node = options.fetch(:node)
  end

  def body
    table.transform(node.to_xml)
  end

  def colspan
    table.num_columns
  end
end
