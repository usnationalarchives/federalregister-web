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
end
