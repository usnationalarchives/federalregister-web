class Search::DocumentsController < ApplicationController
  include ConditionsHelper
  before_filter :load_presenter, except: [:facets, :help]
  skip_before_filter :authenticate_user!

  def header
    render :layout => false
  end

  def show
    if !clean_conditions?
      redirect_to documents_search_path(
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
          render :template => 'documents/index.rss.builder'
        end
        wants.csv do
          redirect_to "http://www.federalregister.gov/api/v1/articles.csv?" + {conditions: params[:conditions]}.to_param
        end
        wants.json do
          redirect_to "http://www.federalregister.gov/api/v1/articles.json?" + {conditions: params[:conditions]}.to_param
        end
      end
   end
  end

  def results
    @search_details = @search.search_details
    #cache_for 1.day
    respond_to do |wants|
      wants.html do
        render :layout => false
      end
      wants.js do
        if @search.valid?
          render :json => {:count => @search.document_count, :message => render_to_string(:partial => "result_summary.txt.erb")}
        else
          render :json => {:errors => @search.validation_errors, :message => "Invalid parameters"}
        end
      end
    end
  end

  def facets
    cache_for 1.day
    @presenter = SearchFacetPresenter::Document.new(params)

    if params[:all]
      render :partial => "search/facet", :collection => @presenter.facets, :as => :facet
    else
      render :partial => "search/facets", :locals => {:facets => @presenter.facets, :name => @presenter.facet_name}, :layout => false
    end
  end

  def suggestions
    cache_for 1.day
    @search_details = @search.search_details
    # RW: necessary?  called from suggestion.html.erb, may have to add when PI is complete
    #if params[:conditions]
    #  @public_inspection_document_search = PublicInspectionDocumentSearch.new_if_possible(
    #    :conditions => @search.valid_conditions
    #  )
    #end
    render :layout => false
  end

  def help
    cache_for 1.day
    if params[:no_layout]
      render :layout => false
    else
      render
    end
  end

  private
  def load_presenter
    @presenter = SearchPresenter::Document.new(params)
    @search = @presenter.search
  end

  def clean_conditions?
    params[:conditions] == clean_conditions(params[:conditions])
  end
end
