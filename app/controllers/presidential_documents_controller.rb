class PresidentialDocumentsController < ApplicationController
  skip_before_filter :authenticate_user!

  def homepage
    cache_for 1.day
    @presenter = PresidentialDocumentsPresenter.new
    render layout: false
  end
end
