class Search::PublicInspectionDocumentsController < ApplicationController
  include ConditionsHelper
  before_filter :load_presenter, except: :facets
  skip_before_filter :authenticate_user!

  def header
    cache_for 1.day
    render layout: false
  end

  def show
    cache_for 1.day

    if valid_search?
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
          @feed_name = "Federal Register: Public Inspection Documents Search Results"
          @feed_description = "Federal Register: Public Inspection Documents Search Results"
          @entries = @search.results
          render :template => 'documents/index.rss.builder'
        end
        wants.csv do
          redirect_to api_v1_entries_url(
            :per_page => 1000,
            :conditions => params[:conditions],
            :fields => [:citation, :document_number, :title, :publication_date, :type, :agency_names, :html_url, :page_length],
            :format => :csv
          )
        end
      end
    end
  end

  def results
    cache_for 1.day
    @search_details = @search.search_details

    respond_to do |wants|
      wants.html do
        render :layout => false
      end
    end
  end

  def facets
    cache_for 1.day
    @presenter = SearchFacetPresenter::PublicInspection.new(params)

    if params[:all]
      render partial: "search/facet", collection: @presenter.facets, as: :facet
    else
      render partial: "search/facets", locals: {
        facets: @presenter.facets
      }, layout: false
    end
  end

  private
  def load_presenter
    @presenter ||= SearchPresenter::PublicInspection.new(params)
    @search = @presenter.search
  end
end
