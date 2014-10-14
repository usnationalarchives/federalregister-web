class ReaderAidsController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
  end

  def blog_highlights
    items = post_collection.posts
    render "esi/reader_aids/blog_full_with_authorship",
      layout: false,
      locals: {
        items: items.first(3),
        icon_class: "icon-fr2-quote",
        show_view_all: (items.count > 3),
        title: "Office of the Federal Register Blog"
      }
  end

  def using_fr
    items = page_collection.
      find_by_parent("Learn")

    render "esi/reader_aids/blog_two_column",
      layout: false,
      locals: {
        items: items.first(6),
        icon_class: "icon-fr2-help",
        show_view_all: (items.count > 6),
        title: "Using FederalRegister.Gov"
      }
  end

  def understanding_fr
    items = page_collection.
      find_by_parent("Learn")

    render "esi/reader_aids/blog_two_column",
      layout: false,
      locals: {
        items: items.first(6),
        icon_class: "icon-fr2-lightbulb-active",
        show_view_all: (items.count > 6),
        title: "Understanding the Federal Register"
      }
  end

  def recent_updates
    items = post_collection.posts

    render "esi/reader_aids/blog_full_without_authorship",
      layout: false,
      locals: {
        items: items.first(4),
        icon_class: "icon-fr2-pc",
        show_view_all: (items.count > 4),
        title: "Recent Site Updates"
      }
  end

  def videos_and_tutorials
    items = page_collection. 
      find_by_parent("Learn")

    render "esi/reader_aids/blog_full_without_authorship",
      layout: false,
      locals: {
        items: items.first(4),
        icon_class: "icon-fr2-movie",
        show_view_all: (items.count > 4),
        title: "Videos & Tutorials"
      }
  end

  def developer_tools
    items = page_collection.
      find_by_parent("Learn").
      first(5)
    render "esi/reader_aids/blog_full_without_authorship",
      layout: false,
      locals: {
        items: items.first(5),
        icon_class: "icon-fr2-tools",
        show_view_all: (items.count > 4),
        title: "Developer Tools"
      }
  end

  private
  def page_collection
    @page_collection ||= WpApi::Client.get_pages
  end

  def post_collection
    @post_collection ||= WpApi::Client.get_posts
  end
end
