class SpecialController < ApplicationController
  skip_before_filter :authenticate_user!
  layout nil 

  def user_utils
    if user_signed_in?
      @document_numbers = current_user.clippings.for_javascript
      @clippings = Clipping.scoped(:conditions => {:folder_id => nil, :user_id => current_user.id}).with_preloaded_articles
      @folders = FolderDecorator.decorate( Folder.scoped(:conditions => {:creator_id => current_user.model}).all )
    elsif cookies[:document_numbers].present?
      @document_numbers = JSON.parse(cookies[:document_numbers])
      @clippings = Clipping.all_preloaded_from_cookie( JSON.parse(cookies[:document_numbers]) )
    else
      @document_numbers = []
      @clippings = []
    end
  end
end
