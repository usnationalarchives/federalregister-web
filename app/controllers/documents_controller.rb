class DocumentsController < ApplicationController
  skip_before_filter :authenticate_user!

  def show
    cache_for 1.day

    begin
      @document = FederalRegister::Article.find(params[:document_number])

      #if request.path != entry_path(@entry)
      #  redirect_to entry_path(@entry), :status => :moved_permanently
      #else
        @document = DocumentDecorator.decorate(@document)
        render
      #end
    rescue FederalRegister::Client::RecordNotFound
      @document = FederalRegister::PublicInspectionDocument.find(params[:document_number])

      #if request.path != entry_path(@public_inspection_document)
      #  redirect_to entry_path(@public_inspection_document), :status => :moved_permanently
      #else
        @document = PublicInspectionDocumentDecorator.decorate(@document)
        render template: 'public_inspection/show'
      #end
    end
  end

  def tiny_url
    cache_for 1.day

    document_or_pi = begin
                       FederalRegister::Document.find(params[:document_number])
                     rescue FederalRegister::Client::RecordNotFound
                       FederalRegister::PublicInspectionDocument.find(params[:document_number])
                     end

    respond_to do |wants|
      wants.html do
        url = document_or_pi.html_url
        if params[:anchor].present?
          url += '#' + params[:anchor]
        end
        redirect_to url, :status => :moved_permanently
      end
      wants.pdf do
        if document_or_pi.is_a?(FederalRegister::Document)
          redirect_to document_or_pi.source_url(:pdf), :status => :moved_permanently
        else
          @public_inspection_document = document_or_pi
          render :template => "public_inspection/not_published.html.erb",
                 :layout => "application.html.erb",
                 :content_type => 'text/html',
                 :status => :not_found
        end
      end
    end
  end
end
