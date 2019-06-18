module ErrorHandler
  extend ActiveSupport::Concern

  def server_error(exception=nil)
    Rails.logger.error(exception)
    Honeybadger.notify(exception)
    render_error(500, "Server Error")
  end

  def not_found#(exception=nil)
    render_error(404, "Not Found")
  end

  def not_authorized(exception=nil)
    render_error(405, "Not Authorized")
  end

  private

  def render_error(status_code, text)
    # ESI routes should return correct status codes, but no error page
    if params[:quiet]
      render head status_code
    else
      respond_to do |format|
        format.html { render template: "errors/#{status_code}", status: status_code }
        format.all { render plain: text, status: status_code }
      end
    end
  end

  included do
    # don't include in dev/test like environments
    unless Rails.application.config.consider_all_requests_local
      rescue_from StandardError, with: :server_error

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from FederalRegister::Client::RecordNotFound, with: :not_found
      rescue_from URI::InvalidURIError, with: :not_found
    end
  end
end