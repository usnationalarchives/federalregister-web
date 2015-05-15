class SectionsController < ApplicationController
  skip_before_filter :authenticate_user!
  layout false, only: :navigation


  def show
    cache_for 1.day

    respond_to do |format|
      begin
      @presenter = SectionPagePresenter.new(params[:section], Date.current)

      format.html
      format.rss do
        redirect_to RSSUrlBuilder.new(@presenter.slug).url, status: :moved_permanently
      end

      rescue SectionPagePresenter::InvalidSection
        raise ActiveRecord::RecordNotFound
      end
      end
  end

  # def old_show_action
  #   @presenter = SectionPresenter.new(params[:section])
  #   @section = @presenter.section

  #   respond_to do |wants|
  #     wants.html
  #     wants.rss do
  #       base_url = 'https://www.federalregister.gov/articles/search.rss?'
  #       options = "conditions[sections]=#{@section.id}&order=newest.com"
  #       redirect_to base_url + options, status: :moved_permanently
  #     end
  #   end
  # end

  def homepage
    @date = DocumentIssue.current.publication_date
    render layout: false
  end

  def significant_entries
    cache_for 1.day
    @presenter = SectionPresenter.new(params[:section])
    @section = @presenter.section

    respond_to do |wants|
      wants.rss do
        base_url = 'https://www.federalregister.gov/articles/search.rss?'
        options = "conditions[sections]=#{@section.id}&order=newest.com&conditions[significant]=1"
        redirect_to base_url + options, status: :moved_permanently
      end
    end
  end

  def navigation
    cache_for 1.day
    @section_presenters = SectionSlug.all.map do |section|
      SectionPagePresenter.new(section.slug, DocumentIssue.current.publication_date - 1.year)
      #TODO: Remove stubbed date
    end
  end
end
