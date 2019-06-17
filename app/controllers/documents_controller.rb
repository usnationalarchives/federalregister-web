class DocumentsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :find_document

  def show
    cache_for 1.day

    respond_to do |wants|
      wants.html do
        if @document.is_a?(Document)
          @document = DocumentDecorator.decorate(@document)
          
          if document_path(@document) == request.path
            render
          else
            redirect_to document_path(@document)
          end
        elsif @document.is_a?(PublicInspectionDocument)
          @document = PublicInspectionDocumentDecorator.decorate(@document)

          if @document.html_url == request.url
            render template: 'public_inspection_documents/show'
          else
            redirect_to @document.html_url
          end
        end
      end

      wants.json do
        if @document.is_a?(Document)
          redirect_to document_api_url(@document, {format: :json})
        elsif @document.is_a?(PublicInspectionDocument)
          redirect_to public_inspection_document_api_url(@document, {format: :json})
        end
      end

      wants.pdf do
        if @document.is_a?(Document) && @document.pdf_url.present?
          redirect_to @document.pdf_url, status: :moved_permanently
        elsif @document.html_url
          redirect_to @document.html_url
        end
      end
    end
  end

  def tiny_url
    cache_for 1.day

    respond_to do |wants|
      wants.html do
        url = @document.html_url

        # the document endpoints can return more than one document
        # if the document number is comma separated in these cases there is
        # no one place to redirect to
        raise ActiveRecord::RecordNotFound unless url

        if params[:anchor].present?
          url += '#' + params[:anchor]
        end

        status = @document.is_a?(Document) ? :moved_permanently : :found # 301 : 302

        redirect_to url, status: status
      end

      wants.pdf do
        if @document.is_a?(Document) && @document.pdf_url.present?
          redirect_to @document.pdf_url, status: :moved_permanently
        elsif @document.html_url
          redirect_to @document.html_url
        else
        end
      end
    end
  end

  private

  def find_document
    begin
      @document = Document.find(params[:document_number])
    rescue FederalRegister::Client::RecordNotFound
      begin
        @document = PublicInspectionDocument.find(params[:document_number])
      rescue FederalRegister::Client::RecordNotFound
        raise ActiveRecord::RecordNotFound
      end
    end
  end
end
