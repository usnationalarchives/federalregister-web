class Search::PublicInspectionDocumentsController < ApplicationController
  include ConditionsHelper
  before_action :load_presenter
  skip_before_action :authenticate_user!

  def show
    cache_for 1.day

    if valid_search?
      respond_to do |wants|
        wants.html

        wants.csv do
          redirect_to public_inspection_search_api_path(
            shared_search_params.merge(
              conditions: params[:conditions],
              per_page: 500
            ),
            format: :csv
          )
        end

        wants.json do
          redirect_to public_inspection_search_api_path(
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

  def search_count
    cache_for 1.day
    valid_conditions = Search::PublicInspection.new(params.permit!.to_h).valid_conditions

    render json: {
      count: ::PublicInspectionDocument.search_metadata(conditions: valid_conditions).count,
      url: public_inspection_search_path(conditions: valid_conditions)
    }
  rescue FederalRegister::Client::BadRequest => e
    render json: {
      count: 0,
      url: public_inspection_search_path(conditions: valid_conditions)
    }
  end

  private

  def load_presenter
    @presenter ||= SearchPresenter::PublicInspection.new(params.permit!.to_h)
    @search = @presenter.search
  end
end
