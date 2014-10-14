module GroupingHelper
  def group_items(items, display_count)
    items = Array(items)
    if items.count < display_count / 2
      items.in_groups_of((display_count/4.0).ceil)
    else
      items.in_groups_of((display_count/2.0).ceil)
    end
  end
end
