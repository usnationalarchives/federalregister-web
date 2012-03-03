class FolderClippingsController < ActionController::Base
  def create
    slug         = params[:folder_clippings][:folder_slug]
    clipping_ids = params[:folder_clippings][:clipping_ids]
    folder       = Folder.find_by_user_and_slug(current_user, slug)
    
    # my-clippings is a "nil" folder
    if (folder.present? || slug == "my-clippings") && clipping_ids.present?
      
      clipping_count = 0
      clipping_ids.each do |id|
        clipping = Clipping.find_by_user_and_id(current_user, id)
        next unless clipping.present?
        
        clipping_count = clipping_count + 1

        clipping.folder_id = folder.present? ? folder.id : nil
        clipping.save
      end
            
      render :json => {:folder => {:name => folder.present? ? folder.name : "my-clippings", 
                                   :slug => slug, 
                                   :doc_count => clipping_count, 
                                   :documents => clipping_ids } }
    elsif ! clipping_ids.present?
      render :text => "No clipping ids present", :status => 400
    else
      render :text => "Unable to find folder with slug '#{slug}'", :status => 404
    end
  end

  def delete
    slug         = params[:folder_clippings][:folder_slug]
    clipping_ids = params[:folder_clippings][:clipping_ids].split(',')
    folder       = Folder.find_by_user_and_slug(current_user, slug)

    # my-clippings is a "nil" folder
    if (folder.present? || slug == "my-clippings") && clipping_ids.present?
      clipping_count = 0
      
      clipping_ids.each do |id|
        clipping = Clipping.find_by_user_and_id(current_user, id)
        next unless clipping.present?
        
        clipping_count = clipping_count + 1
        clipping.destroy
      end

      render :json => {:folder => {:name => folder.present? ? folder.name : "my-clippings", 
                                   :slug => slug, 
                                   :doc_count => clipping_count, 
                                   :documents => clipping_ids } }

    else
      render :text => "No clipping ids present", :status => 400
    end
  end
end
