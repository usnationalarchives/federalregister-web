class SuggestionsController < ApplicationController
  skip_before_action :authenticate_user!
  # include SearchConditionsHelper

  def index
    @suggestions_presenter = SuggestionsPresenter.new(suggestion_params)

    render :index, layout: nil
  end

  private

  def suggestion_params
    params.permit(
      :query,
      :date,
      agencies: []
    ) #TODO: Remove :date
  end
end
