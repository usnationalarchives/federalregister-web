class HtmlCompilator::Tables::HeaderCell
  attr_reader :table, :node
  attr_accessor :descendants, :row, :max_level

  def initialize(options)
    @table = options.fetch(:table)
    @node = options.fetch(:node)
  end

  def children
    @children ||= descendants.reject do |descendant|
      descendants.any? do |other_descendant|
        other_descendant.descendants.include?(descendant)
      end
    end
  end

  def colspan
    if children.present?
      children.sum(&:colspan)
    else
      1
    end
  end

  def rowspan
    row_to_get_to = children.present? ? children.first.level-1 : max_level
    row_to_get_to - level + 1
  end

  def level
    @node.attr('H').to_i
  end

  def body
    @node.text + level.to_s
  end
end
