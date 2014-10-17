class ReaderAidsPresenter
  attr_reader :collection,
              :display_count,
              :icon_class,
              :title,
              :show_authorship,
              :columns,
              :section_identifier,
              :section,
              :parent,
              :items,
              :item_identifier,
              :item
  
  SECTIONS = {
    'blog-highlights'=> {
      title: 'Office of the Federal Register Blog',
      icon_class: 'icon-fr2-quote',
    },
    'using-fr' => {
      title: 'Using FederalRegister.Gov',
      icon_class: 'icon-fr2-help',
    },
    'understanding-fr' => {
      title: 'Understanding the Federal Register',
      icon_class: 'icon-fr2-lightbulb-active',
    },
    'recent-updates' => {
      title: 'Recent Site Updates',
      icon_class: 'icon-fr2-pc',
    },
    'videos-tutorials' => {
      title: 'Videos & Tutorials',
      icon_class: 'icon-fr2-movie',
    },
    'developer-tools' => {
      title: 'Developer Tools',
      icon_class: 'icon-fr2-tools',
    },
  }

  def initialize(options={})
    @section_identifier = options.delete(:section_identifier)
    @item_identifier = options.delete(:item_identifier)
    @section = SECTIONS[section_identifier] || {}
    @title = section[:title]
    @icon_class = section[:icon_class]
    @parent = options.delete(:parent)
    @collection = options.delete(:collection)
    @show_authorship = options.delete(:show_authorship)
    @columns = options.delete(:columns) || 1
    @items = filter_collection if collection
    @display_count = options.delete(:display_count) || items.try(:count)
  end

  def sections
    SECTIONS
  end

  def show_view_all
    items.count > display_count
  end

  def item
    @item ||= items.detect{|item| item.slug == item_identifier}
  end

  def display_items
    items.first(display_count)
  end

  def filter_collection
    if collection.is_a?(WpApi::PageCollection)
      parent ? collection.find_by_parent(parent) : collection.pages
    elsif collection.is_a?(WpApi::PostCollection)
      collection.posts
    end
  end

  def grouped_items
    if columns == 1
      [display_items]
    else
      display_items.
        in_groups_of(display_items.count/2.0.ceil)
    end
  end
end
