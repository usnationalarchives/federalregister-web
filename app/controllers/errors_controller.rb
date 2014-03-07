class ErrorsController < ApplicationController
  skip_before_filter :authenticate_user!

  def server_error
    handle_error(500, "Server Error")
  end

  def record_not_found
    handle_error(404, "Not Found")
  end

  def not_authorized
    handle_error(405, "Not Authorized")
  end

  private

  def handle_error(status_code, text)
    # ESI routes should return correct status codes, but no error page
    if params[:quiet]
      render nothing: true, status: status_code
    else
      respond_to do |format|
        format.html { render template: "errors/#{status_code}", status: status_code }
        format.all { render text: text, status: status_code }
      end
    end
  end
end
