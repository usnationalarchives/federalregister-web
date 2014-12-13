class ExecutiveOrdersController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
    @presenter = ExecutiveOrderPresenter.new(:view_context => view_context)
    @fields = ExecutiveOrderPresenter::FIELDS
    @presidents = President.all.sort_by(&:starts_on).reverse
  end

  def by_president_and_year
    @presenter = ExecutiveOrderPresenter.new(
      president: params[:president],
      year: params[:year]
    )
    @year = params[:year]
    @president = @presenter.president
    @eo_collection = @presenter.eo_collection
  end
end
