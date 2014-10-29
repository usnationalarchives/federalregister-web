class ReaderAidsController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
    @presenter = ReaderAidsPresenter::Base.new
  end

  def search
    @results = WpApi::Client.search(params[:conditions][:term])
  end

  def view_all
    if %w(blog-highlights recent-updates).include?(params[:section])
      @presenter = ReaderAidsPresenter.new(
        collection: post_collection,
        section_identifier: params[:section],
      )
    else
      @presenter = ReaderAidsPresenter.new(
        collection: page_collection,
        parent: params[:parent],
        section_identifier: params[:section],
      )
    end
  end

  def show
    @presenter = ReaderAidsPresenter.new(
      collection: page_collection,
      section_identifier: params[:section],
      item_identifier: params[:item]
    )
  end

  def blog_highlights
    presenter = ReaderAidsPresenter.new(
      collection: post_collection,
      display_count: 3,
      section_identifier: 'blog-highlights',
      show_authorship: true,
    )
        
    render "esi/reader_aids/section",
      layout: false,
      locals: { presenter: presenter }
  end

  def using_fr
    presenter = ReaderAidsPresenter.new(
      collection: page_collection,
      parent: 'Learn',
      display_count: 6,
      section_identifier: 'using-fr',
      columns: 2
    )

    render "esi/reader_aids/section",
      layout: false,
      locals: { presenter: presenter }
  end

  def understanding_fr
    presenter = ReaderAidsPresenter.new(
      collection: page_collection,
      parent: 'Learn',
      display_count: 6,
      section_identifier: 'understanding-fr',
      columns: 2
    )

    render "esi/reader_aids/section",
      layout: false,
      locals: { presenter: presenter }
  end

  def recent_updates
    presenter = ReaderAidsPresenter.new(
      collection: post_collection,
      display_count: 3,
      section_identifier: 'recent-updates',
    )

    render "esi/reader_aids/section",
      layout: false,
      locals: { presenter: presenter }
  end

  def videos_and_tutorials
    presenter = ReaderAidsPresenter.new(
      collection: page_collection,
      parent: 'Learn',
      display_count: 3,
      section_identifier: 'videos-tutorials',
    )

    render "esi/reader_aids/section",
      layout: false,
      locals: { presenter: presenter }
  end

  def developer_tools
    presenter = ReaderAidsPresenter.new(
      collection: page_collection,
      parent: 'Learn',
      display_count: 3,
      section_identifier: 'developer-tools',
    )
    render "esi/reader_aids/section",
      layout: false,
      locals: { presenter: presenter }
  end

  private
  def page_collection
    @page_collection ||= WpApi::Client.get_pages
  end

  def post_collection
    @post_collection ||= WpApi::Client.get_posts
  end
end
