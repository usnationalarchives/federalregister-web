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
  delegate :h, :to => :table

  def initialize(options)
    @table = options.fetch(:table)
    @node = options.fetch(:node)
  end

  def to_html
    h.content_tag(:tr) {
      h.concat h.content_tag(:td, body, colspan: table.num_columns)
    }
  end

  def body
    table.transform(node.to_xml)
  end
end
