class ClippingsController < ApplicationController
  protect_from_forgery :except => :create

  def index
    @clippings = current_user.clippings.with_preloaded_articles
  end

  def create
    unless Clipping.find_by_document_number_and_user_id(params[:entry][:document_number], current_user.id)
      @clipping = Clipping.new(:document_number => params[:entry][:document_number],
                               :user_id => current_user.id)
      @clipping.save
    end

    redirect_to clippings_url
  end
end
