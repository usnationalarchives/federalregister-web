class HtmlCompilator::Tables::FooterRow
  def self.generate(options)
    table = options.fetch(:table)
    table.node.xpath('TNOTE').map do |node|
      new(
        :table => table,
        :node => node
      )
    end
  end

  attr_reader :table, :node

  def initialize(options)
    @table = options.fetch(:table)
    @node = options.fetch(:node)
  end

  def cells
    [HtmlCompilator::Tables::FooterCell.new(row: self, node: node)]
  end
end
