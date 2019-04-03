class ApiDocumentationController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token

  def show
    respond_to do |format|
      format.html do
      end
      format.json do
        render json: SwaggerJsonBuilder.new(request).as_json
      end
    end
  end

end
