class PublicInspectionDocumentsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :find_document
  include DocumentLookup

  def show
    cache_for 1.day

    respond_to do |wants|
      wants.html do
        if @document.is_a?(Document)
          @document = DocumentDecorator.decorate(@document)

          redirect_to document_path(@document)
        elsif @document.is_a?(PublicInspectionDocument)
          @document = PublicInspectionDocumentDecorator.decorate(@document)

          if @document.revoked_and_older_date?
            render_error(404, "Not Found")
          elsif URI::parse(@document.html_url).path == request.path
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

end
