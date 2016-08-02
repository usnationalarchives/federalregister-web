class SuggestedSearchesController < ApplicationController
  skip_before_filter :authenticate_user!

  def show
    cache_for 1.day
    @presenter = SuggestedSearchPresenter.new(params[:slug])

  rescue SuggestedSearchPresenter::InvalidSuggestedSearch
    raise ActiveRecord::RecordNotFound
  end

end
