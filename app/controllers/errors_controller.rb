class ErrorsController < ApplicationController
  def server_error
    handle_error(500)
  end

  def record_not_found
    handle_error(404)
  end

  def not_authorized
    handle_error(405)
  end

  private

  def handle_error(status_code)
    # ESI routes should return correct status codes, but no error page
    if params[:quiet]
      render :nothing => true, :status => status_code
    else
      request.format = :html
      render :template => "errors/#{status_code}", :status => status_code
    end
  end
end
