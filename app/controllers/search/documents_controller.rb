class Search::DocumentsController < ApplicationController
  include ConditionsHelper
  before_action :load_presenter, except: [:help]
  skip_before_action :authenticate_user!

  DEFAULT_CSV_MAXIMUM_PER_PAGE = 1000
  def show
    cache_for 1.day

    if valid_search?
      respond_to do |wants|
        wants.html do
          if disallowed_subscription_params?
            @subscription_search = SearchPresenter::Document.new(subscription_params.permit!.to_h).search
          else
            @subscription_search = @search
          end
        end

        wants.csv do
          redirect_to documents_search_api_path(
            shared_search_params.merge(
              conditions: params[:conditions],
              per_page: params[:per_page] || DEFAULT_CSV_MAXIMUM_PER_PAGE
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
