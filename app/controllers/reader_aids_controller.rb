class ReaderAidsController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :verify_section_exists, only: :view_all

  def index
    @presenter = ReaderAidsPresenter::Base.new
  end

  def search
    @results = WpApi::Client.search(params[:conditions][:term])
  end

  def view_all
    @presenter = ReaderAidsPresenter::SectionPresenter.new(
      section_identifier: params[:section]
    )
  end

  def show
    @presenter = ReaderAidsPresenter::SectionPresenter.new(
      section_identifier: params[:section],
      item_identifier: params[:item]
    )
  end

  def blog_highlights
    render_section(
      ReaderAidsPresenter::SectionPresenter.new(
        display_count: 3,
        section_identifier: 'office-of-the-federal-register-blog'
      )
    )
  end

  def using_fr
    render_section(
      ReaderAidsPresenter::SectionPresenter.new(
        display_count: 6,
        section_identifier: 'using-federalregister-gov',
        columns: 2
      )
    )
  end

  def understanding_fr
    render_section(
      ReaderAidsPresenter::SectionPresenter.new(
        display_count: 6,
        section_identifier: 'understanding-the-federal-register',
        columns: 2
      )
    )
  end

  def recent_updates
    render_section(
      ReaderAidsPresenter::SectionPresenter.new(
        display_count: 3,
        section_identifier: 'recent-updates',
        category: 'site-updates'
      )
    )
  end

  def videos_and_tutorials
    render_section(
      ReaderAidsPresenter::SectionPresenter.new(
        display_count: 3,
        section_identifier: 'videos-tutorials',
      )
    )
  end

  def developer_tools
    render_section(
      ReaderAidsPresenter::SectionPresenter.new(
        display_count: 3,
        section_identifier: 'developer-tools',
      )
    )
  end

  private

  def render_section(presenter)
    render "section",
      layout: false,
      locals: { presenter: presenter }
  end

  def verify_section_exists
    raise ActiveRecord::RecordNotFound unless ReaderAidsPresenter::Base.new.sections.include?(params[:section])
  end
end
