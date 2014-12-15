class ExecutiveOrdersController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
    @presenter = ExecutiveOrderPresenter.new(
      view_context: view_context
    )
    @presidents = President.
      all.
      sort_by(&:starts_on).
      reverse
  end

  def by_president_and_year
    @presenter = ExecutiveOrderPresenter.new(
      view_context: view_context,
      president: params[:president],
      year: params[:year]
    )
  end
end
