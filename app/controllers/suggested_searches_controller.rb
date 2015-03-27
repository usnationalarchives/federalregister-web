class SuggestedSearchesController < ApplicationController
  skip_before_filter :authenticate_user!

  def show
    begin
    @presenter = SuggestedSearchPresenter.new(SuggestedSearch.search(conditions: {sections: ['money']})['money'].first)
    #TODO: Add API Endpoint search instead of stub.
    rescue SuggestedSearchPresenter.InvalidSuggestedSearch
      raise ActiveRecord::RecordNotFound
    end
  end

end