class HtmlCompilator::Tables::BodyRow
  attr_reader :table, :node
  def initialize(options)
    @table = options.fetch(:table)
    @node = options.fetch(:node)
  end

  def cells
    @cells ||= node.xpath('ENT').map do |node|
      HtmlCompilator::Tables::BodyCell.new(:row => self, :node => node)
    end
  end

  def expanded_stub_width
    @expanded_stub_width ||= node.attr('EXPSTB').try(:to_i) ||
      prior_row.try(:expanded_stub_width) ||
      0
  end

  def prior_row
    index = table.body_rows.index(self)
    if index > 0
      table.body_rows[index-1]
    end
  end
end
