class ClippingsController < ApplicationController
  protect_from_forgery :except => [:create, :bulk_create]
  skip_before_filter :authenticate_user!, :only => [:index, :create]

  def index
    if user_signed_in? && current_user.clippings.present?
      clipboard_clippings = Clipping.scoped(:conditions => {:folder_id => nil, :user_id => current_user.id}).with_preloaded_articles
    elsif !user_signed_in? && cookies[:document_numbers].present?
      clipboard_clippings = Clipping.all_preloaded_from_cookie( cookies[:document_numbers] )
    else
      clipboard_clippings = []
    end
    
    clipboard_clippings ||= []

    @folders   = FolderDecorator.decorate( Folder.scoped(:conditions => {:creator_id => current_user.model}).all ) if user_signed_in?
    @folder    = Folder.new(:name => 'My Clipboard', :slug => "my-clippings")
    @clippings = ClippingDecorator.decorate(clipboard_clippings)
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
      render :json => {:folder => {:name => 'My Clippings', :slug => 'my-clippings' } }
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
    params.require(:entry).permit(:document_number, :folder)
  end

  def add_document_id_to_session(document_number)
    if cookies[:document_numbers].present?
      cookies.permanent[:document_numbers] = JSON.parse(cookies[:document_numbers]).push( {document_number => ['my-clippings']} ).to_json
    else
      cookies.permanent[:document_numbers] = [{document_number => ['my-clippings']}].to_json
    end
  end
end
