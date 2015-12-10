module FrBoxHelper
  def fr_content_box(fr_box, &block)
    FrBoxHtmlBuilder.new(fr_box, self, &block).fr_box
  end

  def fr_details_box(fr_box, &block)
    FrBoxHtmlBuilder.new(fr_box, self, &block).fr_box_small
  end

  def fr_utility_nav_box(fr_box, &block)
    FrBoxHtmlBuilder.new(fr_box, self, &block).fr_box_utility
  end

  def fr_tooltip_box(fr_box, &block)
    FrBoxHtmlBuilder.new(fr_box, self, &block).fr_box_tooltip
  end
end
