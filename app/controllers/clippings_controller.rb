class ClippingsController < ApplicationController
  skip_before_action :authenticate_user!, :only => [:index, :create]

  def index
    if user_signed_in? && current_user.clippings.present?
      clipboard_clippings = Clipping.
        where(folder_id: nil, user_id: current_user.id).
        with_preloaded_documents

      #ensure not nil
      clipboard_clippings = clipboard_clippings ? clipboard_clippings : []
    elsif !user_signed_in?
      redirect_to sign_in_url(nil, {info: I18n.t('clippings.sign_in_required')})
    else
      clipboard_clippings = []
    end

    if user_signed_in?
      @folders = FolderDecorator.decorate( current_user.folders )
    end

    @folder    = Folder.my_clipboard
    @clippings = ClippingDecorator.decorate_collection(clipboard_clippings)
  end

  def create
    if user_signed_in?
      # create a clipping unless one already exists for this document
      Clipping.persist_document(current_user, clipping_attributes[:document_number], clipping_attributes[:folder] )
    else
      # stash the document id in the session if the user isn't logged in
      add_document_id_to_session( clipping_attributes[:document_number] )
    end

    if request.xhr?
      render json: {
        folder: {name: 'My Clippings', slug: 'my-clippings' }
      }
    else
      redirect_to clippings_url
    end

  end

  def bulk_create
    document_numbers = Array( params[:document_numbers] ).flatten

    if document_numbers.present?
      clipping_details = []
      document_numbers.each do |document_number|
        unless Clipping.find_by_document_number_and_user_id(document_number, current_user.id)
          clipping = Clipping.new(:document_number => document_number,
                                  :user_id => current_user.id)
          clipping.save

          clipping_details << { :doc_type   => clipping.article.type,
                                :title      => clipping.article.title,
                                :url        => clipping.article.html_url,
                                :pub_date   => clipping.article.publication_date,
                                :created_at => clipping.created_at }
        end
      end
    end

    render :json => {:clippings => clipping_details}
  end

  private

  def clipping_attributes
    params.require(:document).permit(:document_number, :folder)
  end

  def add_document_id_to_session(document_number)
      cookies.permanent[:document_numbers] = [{document_number => ['my-clippings']}].to_json
  end
end
