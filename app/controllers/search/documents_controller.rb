class Search::DocumentsController < ApplicationController
  include ConditionsHelper
  before_action :load_presenter, except: [:facets, :help]
  skip_before_action :authenticate_user!

  def header
    cache_for 1.day
    render :layout => false
  end

  def show
    cache_for 1.day

    if valid_search?
      respond_to do |wants|
        wants.html do
          if disallowed_subscription_params?
            @subscription_search = SearchPresenter::Document.new(subscription_params).search
          else
            @subscription_search = @search
          end
        end

        wants.csv do
          redirect_to documents_search_api_path(
            shared_search_params.merge(
              conditions: params[:conditions],
              per_page: 1000
            ),
            format: :csv
          )
        end

        wants.json do
          redirect_to documents_search_api_path(
            shared_search_params.merge(conditions: params[:conditions]),
            format: :json
          )
        end
      end
    else
      redirect_to clean_search_path
    end
  end

  def results
    cache_for 1.day
    @search_details = @search.search_details
    @facet_presenter = SearchFacetPresenter::Document.new(
      facet_params.to_h,
      view_context
    )

    respond_to do |wants|
      wants.html do
        render :layout => false
      end
    end
  end

  def facets
    cache_for 1.day
    @presenter = SearchFacetPresenter::Document.new(
      facet_params.to_h,
      view_context
    )

    if params[:all]
      render partial: "search/facet", collection: @presenter.facets, as: :facet
    else
      render partial: "search/facets", locals: {
        facets: @presenter.facets
      }, layout: false
    end
  end

  def suggestions
    cache_for 1.day
    @search_details = @search.search_details

    render :layout => false
  end

  def help
    redirect_to reader_aids_search_help_url
  end

  def search_count
    cache_for 1.day
    valid_conditions = Search::Document.new(params.permit!.to_h).valid_conditions

    render json: {
      count: ::Document.search_metadata(conditions: valid_conditions).count,
      url: documents_search_path(conditions: valid_conditions)
    }
  rescue FederalRegister::Client::BadRequest => e
    render json: {
      count: 0,
      url: documents_search_path(conditions: valid_conditions)
    }
  end

  private

  def load_presenter
    @presenter = SearchPresenter::Document.new(params.permit!.to_h)
    @search = @presenter.search
  end

  def facet_params
    facet_params = params.permit(
      :all,
      :facet,
      :order,
      conditions: {}
    )

    facet_params[:conditions] = Search::Document.new(facet_params.to_h).valid_conditions
    facet_params
  end
  DISALLOWED_SUBSCRIPTION_SEARCH_PARAMS = 'publication_date', 'effective_date', 'comment_date'
  def subscription_params
    ActionController::Parameters.new({
      conditions: params[:conditions].except(*DISALLOWED_SUBSCRIPTION_SEARCH_PARAMS)
    })
  end

  def disallowed_subscription_params?
    params[:conditions] &&
    DISALLOWED_SUBSCRIPTION_SEARCH_PARAMS.any?{|x| params[:conditions] && params[:conditions][x]}
  end

end
