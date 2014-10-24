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
end
