class ReaderAidsPresenter::SectionPresenter < ReaderAidsPresenter::Base
  attr_reader :category,
              :columns,
              :display_count,
              :item_identifier,
              :section_identifier

  def initialize(config)
    @columns = config.fetch(:columns) { 1 }
    @display_count = config.fetch(:display_count) { nil }
    @item_identifier = config.fetch(:item_identifier) { nil }
    @section_identifier = config.fetch(:section_identifier) { nil }
    @category = config.fetch(:category) { nil }
  end

  def section
    sections.fetch(section_identifier)
  end

  def type
    section.fetch(:type)
  end

  def title
    section.fetch(:title)
  end

  def icon_class
    section.fetch(:icon_class)
  end

  def show_authorship?
    section.fetch(:show_authorship) { false }
  end

  def pages_collection
    @pages_collection ||= WpApi::Client.get_pages(
      filters: {
        parent_slug: section_identifier
        #orderby: 'menu_order',
        #order: 'ASC'
      }
    )
  end

  def posts_collection
    config = category ? {filters: {category_name: category}} : {}

    return @posts_collection if @posts_collection

    @posts_collection = WpApi::Client.get_posts(config)
    if section_identifier == 'office-of-the-federal-register-blog'
      @posts_collection.content = @posts_collection.posts.reject{|p| p.categories.include?('site-updates')}
    end
    @posts_collection
  end

  def show_view_all
    items.count > display_count
  end

  def item
    @item ||= items.detect{|item| item.slug == item_identifier}
  end

  def parent
    section_identifier if collection.is_a?(WpApi::PageCollection)
  end

  def items
    @items ||= type == 'pages' ? pages_collection.content : posts_collection.content
  end

  def items_for_display
    display_count.nil? ? items : items.first(display_count)
  end

  def grouped_items
    if columns == 1
      [items_for_display]
    else
      items_for_display.
        in_groups_of(items_for_display.count/(columns.to_f).ceil)
    end
  end

  def css_columns
    grid_width = 12
    col_width = grid_width / columns

    "col-xs-#{col_width} col-md-#{col_width}"
  end
end
