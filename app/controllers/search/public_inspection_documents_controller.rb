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
      respond_to do |wants|
        wants.html

        wants.csv do
          redirect_to public_inspection_search_api_url(
            shared_search_params.merge(
              conditions: params[:conditions],
              per_page: 500
            ),
            :format => :csv
          )
        end

        wants.json do
          redirect_to public_inspection_search_api_url(
            shared_search_params.merge(
              conditions: params[:conditions]
            ),
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
