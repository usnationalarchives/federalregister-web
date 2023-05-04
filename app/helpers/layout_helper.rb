module LayoutHelper
  def add_column_class(column_class)
    content_for :column_class do
      "#{column_class}"
    end
  end

  def page_controller(identifier)
    content_for :page_controller, identifier
  end

  def page_action(identifier)
    content_for :page_action, identifier
  end

  def make_layout_fixed_width
    content_for :layout_css_class, "fixed-width-layout"
  end
end
