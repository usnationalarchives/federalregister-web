class FolderClippingsController < ActionController::Base
  def create
    slug         = params[:folder_clippings][:folder_slug]
    clipping_ids = params[:folder_clippings][:clipping_ids]
    folder       = Folder.find_by_user_and_slug(current_user, slug)
    
    if folder.present? && clipping_ids.present?
      
      clipping_ids.each do |id|
        clipping = Clipping.find_by_user_and_id(current_user, id)
        next unless clipping.present?
      
        clipping.folder_id = folder.id
        clipping.save
      end
      
      redirect_to clippings_url
    elsif ! clipping_ids.present?
      render :text => "No clipping ids present", :status => 400
    else
      render :text => "Unable to find folder with slug '#{slug}'", :status => 404
    end
  end
end
