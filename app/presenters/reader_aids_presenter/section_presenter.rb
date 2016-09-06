class ReaderAidsPresenter::SectionPresenter < ReaderAidsPresenter::Base
  attr_reader :category,
              :columns,
              :display_count,
              :item_partial,
              :item_ul_class,
              :page_identifier,
              :section_identifier,
              :subpage_identifier

  attr_accessor :per_page_offset

  RESULTS_PER_PAGE = 100 #seems to be max allowed by WP

  def initialize(config)
    @section_identifier = config.fetch(:section_identifier) { nil }
    @page_identifier = config.fetch(:page_identifier) { nil }
    @subpage_identifier = config.fetch(:subpage_identifier) { nil }

    @category = config.fetch(:category) { nil }
    @item_partial = config.fetch(:item_partial) { 'item' }
    @item_ul_class = config.fetch(:item_ul_class) { '' }

    @columns = config.fetch(:columns) { 1 }
    @display_count = config.fetch(:display_count) { nil }

    @per_page_offset = 0
  end

  def section
    sections.fetch(section_identifier)
  end

  def section_page
    @section_page ||= type == 'pages' ? WpApi::Client.get_page(slug: section_identifier) : nil
  end

  def section_settings
    section[:index_settings]
  end

  def type
    section.fetch(:type)
  end

  def page_slug
    [section_identifier, page_identifier, subpage_identifier].
      compact.
      join('/')
  end

  def commentable?
    type == "posts"
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
    config = {
      parent_slug: parent_identifier,
      per_page: RESULTS_PER_PAGE,
      offset: @per_page_offset
    }

    pages_collection = WpApi::Client.get_pages(config)
  end

  def posts_collection
    config = category ? {filter: {category_name: category}} : {}

    config.merge!({
      per_page: RESULTS_PER_PAGE,
      offset: @per_page_offset
    })

    posts_collection = WpApi::Client.get_posts(config)

    if section_identifier == 'office-of-the-federal-register-blog'
      posts_collection.content = posts_collection.posts.reject do |post|
        post.categories.map{|c| c.slug}.include?('site-updates')
      end
    elsif section_identifier == 'recent-updates'
      posts_collection.content = posts_collection.posts.select do |post|
        post.categories.map{|c| c.slug}.include?('site-updates')
      end
    end

    posts_collection
  end

  def show_view_all
    true #items.count > display_count
  end

  def item
    return @item if @item

    if items.present?
      matched_item = items.detect{|item| item.slug == item_identifier}

      if matched_item
        @item = matched_item
      else
        @per_page_offset = @per_page_offset + RESULTS_PER_PAGE
        item
      end
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def parent
    section_identifier if collection.is_a?(WpApi::PageCollection)
  end

  def items
    items = type == 'pages' ? pages_collection.content.sort_by(&:menu_order) : posts_collection.content
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

  private

  def item_identifier
    subpage_identifier ? subpage_identifier : page_identifier
  end

  def parent_identifier
    subpage_identifier ? page_identifier : section_identifier
  end
end
