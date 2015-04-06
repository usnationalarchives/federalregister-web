class HtmlCompilator::Tables::Footer
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

  def body
    table.transform(node.to_xml)
  end
end
