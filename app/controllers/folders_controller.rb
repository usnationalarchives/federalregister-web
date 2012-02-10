class FoldersController < ActionController::Base
  def show
    @folders   = FolderDecorator.decorate( Folder.scoped(:conditions => {:creator_id => current_user}).all )
    @folder    = Folder.find_by_user_and_slug(current_user, params[:id])
    @clippings = ClippingDecorator.decorate(@folder.clippings)
    
    render 'clippings/index', :layout => "application"
  end
end
