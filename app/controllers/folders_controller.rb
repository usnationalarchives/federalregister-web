class FoldersController < ActionController::Base
  
  def create
    folder = Folder.new(:name => params[:folder][:name], :creator_id => current_user.id, :updater_id => current_user.id)
    document_numbers = params[:folder][:document_numbers]

    if folder.save
      document_numbers.each do |document_number|
        clipping = Clipping.new(:document_number => document_number, :folder_id => folder.id, :user_id => current_user.id)
        clipping.save
      end
    end

    if request.xhr?
      folder.reload
      render :json => {:folder => {:name => folder.name, :slug => folder.slug, :doc_count => folder.clippings.count, :documents => folder.document_numbers } }
    end
  end

  def show
    @folders   = FolderDecorator.decorate( Folder.scoped(:conditions => {:creator_id => current_user}).all )
    @folder    = Folder.find_by_user_and_slug(current_user, params[:id])
    @clippings = @folder.clippings.present? ? ClippingDecorator.decorate(@folder.clippings) : []
    
    render 'clippings/index', :layout => "application"
  end
end
