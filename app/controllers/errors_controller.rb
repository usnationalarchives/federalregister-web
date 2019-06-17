# class ErrorsController < ApplicationController
#   skip_before_action :authenticate_user!

#   def server_error
#     handle_error(500, "Server Error")
#   end

#   def record_not_found
#     binding.remote_pry
#     handle_error(404, "Not Found")
#   end

#   def not_authorized
#     handle_error(405, "Not Authorized")
#   end

#   private

#   def handle_error(status_code, text)
#     # ESI routes should return correct status codes, but no error page
#     if params[:quiet]
#       render head status_code
#     else
#       respond_to do |format|
#         format.html { render template: "errors/#{status_code}", status: status_code }
#         format.all { render plain: text, status: status_code }
#       end
#     end
#   end
# end
