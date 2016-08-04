class ExecutiveOrdersController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
    cache_for 1.day
    @presenter = ExecutiveOrderPresenter.new(
      view_context: view_context
    )
    @presidents = President.
      all.
      sort_by(&:starts_on).
      reverse
  end

  def by_president_and_year
    cache_for 1.day
    @presenter = EoDispositionTablePresenter.new(
      view_context: view_context,
      president: params[:president],
      year: params[:year]
    )

    raise ActiveRecord::RecordNotFound unless @presenter.eo_collection.results.present?
  end

  def navigation
    cache_for 1.day
    @presenter = ExecutiveOrderNavPresenter.new
    render layout: false
  end
end
