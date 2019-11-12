class ApiDocumentationController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

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
