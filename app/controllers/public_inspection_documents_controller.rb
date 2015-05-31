class PublicInspectionDocumentsController < ApplicationController
  skip_before_filter :authenticate_user!
  layout false, only: :navigation

end
