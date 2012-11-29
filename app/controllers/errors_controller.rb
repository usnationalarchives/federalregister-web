class ErrorsController < ApplicationController
  def server_error
    # ESI routes should return correct status codes, but no error page
    if params[:quiet]
      render :nothing => true, :status => 500
    else
      request.format = :html
      render :template => "errors/500", :status => 500
    end
  end

  def record_not_found
    # ESI routes should return correct status codes, but no error page
    if params[:quiet]
      render :nothing => true, :status => 404
    else
      request.format = :html
      render :template => "errors/404", :status => 404
    end
  end

  def not_authorized
    # ESI routes should return correct status codes, but no error page
    if params[:quiet]
      render :nothing => true, :status => 405
    else
      request.format = :html
      render :template => "errors/405", :status => 405
    end
  end
end
