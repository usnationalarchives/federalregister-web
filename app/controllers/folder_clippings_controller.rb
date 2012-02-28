class FolderClippingsController < ActionController::Base
  def create
    slug         = params[:folder_clippings][:folder_slug]
    clipping_ids = params[:folder_clippings][:clipping_ids]
    folder       = Folder.find_by_user_and_slug(current_user, slug)
    
    if folder.present? && clipping_ids.present?
      
      clipping_count = 0
      clipping_ids.each do |id|
        clipping = Clipping.find_by_user_and_id(current_user, id)
        next unless clipping.present?
        
        clipping_count = clipping_count + 1

        clipping.folder_id = folder.id
        clipping.save
      end
            
      render :json => {:folder => {:name => folder.name, :slug => folder.slug, :doc_count => clipping_count, :documents => clipping_ids } }
    elsif ! clipping_ids.present?
      render :text => "No clipping ids present", :status => 400
    else
      render :text => "Unable to find folder with slug '#{slug}'", :status => 404
    end
  end
end
