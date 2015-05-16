class ExecutiveOrdersController < ApplicationController
  skip_before_filter :authenticate_user!
  def by_president_and_year
    @presenter = ExecutiveOrderPresenter.new(
      president: params[:president],
      year: params[:year]
    )
    @year = params[:year]
    @president = @presenter.president
    @eo_collection = @presenter.eo_collection
  end

  def navigation
    cache_for 1.day
    @presenter = ExecutiveOrderNavPresenter.new
    render template: "executive_orders/navigation", layout: false
  end
end
