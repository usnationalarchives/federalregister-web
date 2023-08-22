class V1::ClippingsController < ApiController
  skip_before_action :authenticate_user!

  def index
    clipboard = Folder.my_clipboard

    if user_signed_in?
      @clippings = Clipping.where(user_id: current_user.id).
        includes(:folder).
        with_preloaded_documents

      @folders = @clippings.nil? ? [] : @clippings.map(&:folder).uniq

      # roll up clippings not in a folder into the clipboard
      clipboard_clippings = @clippings&.select{|c| c.folder_id.nil?} || []
      clipboard.doc_count = clipboard_clippings.count
      clipboard.documents = clipboard_clippings.map(&:document_number)
      clipboard.document_types = clipboard_clippings.map{|c| c.document.type.downcase.gsub(" ", "_")}.uniq.compact

      @folders = @folders.compact.prepend(clipboard)
    else
      @clippings = []
      @folders = [clipboard]
    end

    clippings_response = ActiveModelSerializers::SerializableResource.new(
      @clippings,
      each_serializer: V1::ClippingSerializer
    ).as_json

    folders_response = ActiveModelSerializers::SerializableResource.new(
      @folders,
      each_serializer: V1::FolderSerializer
    ).as_json

    render json: {
      clippings: clippings_response,
      folders: folders_response
    }
  end
end
