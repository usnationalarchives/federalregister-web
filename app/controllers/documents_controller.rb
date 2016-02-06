class DocumentsController < ApplicationController
  skip_before_filter :authenticate_user!

  def show
    cache_for 1.day

    begin
      @document = Document.find(params[:document_number])

      @document = DocumentDecorator.decorate(@document)

      if document_path(@document) == request.path
        render
      else
        redirect_to document_path(@document)
      end
    rescue FederalRegister::Client::RecordNotFound
      @document = FederalRegister::PublicInspectionDocument.find(params[:document_number])

      @document = PublicInspectionDocumentDecorator.decorate(@document)
      if @document.html_url == request.url
        render template: 'public_inspection_documents/show'
      else
        redirect_to @document.html_url
      end
    end
  end

  def tiny_url
    cache_for 1.day

    document_or_pi = begin
                       Document.find(params[:document_number])
                     rescue FederalRegister::Client::RecordNotFound
                       PublicInspectionDocument.find(params[:document_number])
                     end

    respond_to do |wants|
      wants.html do
        url = document_or_pi.html_url

        if params[:anchor].present?
          url += '#' + params[:anchor]
        end

        redirect_to url, status: :moved_permanently
      end

      wants.pdf do
        if document_or_pi.is_a?(Document)
          redirect_to document_or_pi.pdf_url, status: :moved_permanently
        else
          redirect_to document_or_pi.html_url
        end
      end
    end
  end
end
