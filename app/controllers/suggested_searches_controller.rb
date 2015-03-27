class SuggestedSearchesController < ApplicationController
  skip_before_filter :authenticate_user!

  def show
    @presenter = SuggestedSearchPresenter.new(SuggestedSearch.search(conditions: {sections: ['money']})['money'].first)
  end

end