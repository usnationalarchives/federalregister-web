class PresidentialDocumentsController < ApplicationController
  skip_before_filter :authenticate_user! #TODO: Not require this

  def homepage
    @presenter = PresidentialDocumentsPresenter.new
    render layout: false
  end
end
