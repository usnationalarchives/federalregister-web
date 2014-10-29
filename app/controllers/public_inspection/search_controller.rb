class PublicInspection::SearchController < SearchController
  skip_before_filter :authenticate_user!

  def header
    @presenter ||= SearchPresenter.new(params)
    @search = @presenter.search
    render layout: false
  end

  def show
    @presenter ||= SearchPresenter.new(params)
    @search = @presenter.search
    if blank_conditions?(params[:conditions]) || ((params[:conditions].try(:keys) || []) - @search.valid_conditions.try(:keys)).present?
      redirect_to public_inspection_search_path(
        conditions: clean_conditions(@search.valid_conditions),
        page: params[:page],
        order: params[:order],
        format: params[:format]
      )
    else
      respond_to do |wants|
        wants.html
        wants.rss do
          @feed_name = "Federal Register: Search Results"
          @feed_description = "Federal Register: Search Results"
          @entries = @search.results
          render :template => 'entries/index.rss.builder'
        end
        wants.csv do
          redirect_to api_v1_entries_url(:per_page => 1000, :conditions => params[:conditions], :fields => [:citation, :document_number, :title, :publication_date, :type, :agency_names, :html_url, :page_length], :format => :csv) 
        end
      end
    end
  end
end
