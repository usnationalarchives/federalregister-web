class ReaderAidsController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :verify_section_exists, only: :view_all
  layout false, only: [:navigation, :homepage, :index_section]

  def index
    cache_for 1.hour
    @presenter = ReaderAidsPresenter::Base.new
  end

  def search
    cache_for 1.hour
    @search_presenter = ReaderAidsPresenter::SearchPresenter.new(
      params[:conditions][:term]
    )
  end

  def section
    cache_for 1.hour
    @presenter = ReaderAidsPresenter::SectionPresenter.new(
      section_identifier: params[:section]
    )
  end

  def show
    cache_for 1.hour

    if params[:subpage] && params[:subpage].include?('/')
      raise ActiveRecord::RecordNotFound
    end

    @presenter = ReaderAidsPresenter::SectionPresenter.new(
      section_identifier: params[:section],
      page_identifier: params[:page],
      subpage_identifier: params[:subpage]
    )
  end

  def homepage
    cache_for 1.hour
    
    @using_fr_presenter = ReaderAidsPresenter::IndexSectionPresenter.new(
      section_identifier: 'using-federalregister-gov',
      display_count: 8,
      columns: 2,
      item_partial: 'reader_aids/homepage_item',
      item_ul_class: "with-bullets reader-aids"
    )
    @recent_updates_presenter = ReaderAidsPresenter::IndexSectionPresenter.new(
      display_count: 4,
      section_identifier: 'recent-updates',
      category: 'site-updates',
      columns: 1,
      item_partial: 'reader_aids/homepage_item',
      item_ul_class: "with-bullets reader-aids"
    )
  end

  # esi for main reader-aids page
  def index_section
    cache_for 1.hour

    @presenter = ReaderAidsPresenter::IndexSectionPresenter.new(
      section_identifier: params[:section]
    )

    render locals: {presenter: @presenter}
  end

  def navigation
    cache_for 1.day

    @reader_aids_sections = ReaderAidsPresenter::Base.new.sections
  end

  private

  def verify_section_exists
    raise ActiveRecord::RecordNotFound unless ReaderAidsPresenter::Base.new.sections.include?(params[:section])
  end
end
