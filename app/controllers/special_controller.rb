class SpecialController < ApplicationController
  skip_before_filter :authenticate_user!
  layout nil 

  def user_utils
    if user_signed_in?
      @document_numbers = current_user.clippings.for_javascript 
      @folders = FolderDecorator.decorate( Folder.scoped(:conditions => {:creator_id => current_user.model}).all )
    elsif cookies[:document_numbers].present?
      @document_numbers = JSON.parse(cookies[:document_numbers])
    else
      @document_numbers = []
    end
  end
end
