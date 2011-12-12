class SpecialController < ApplicationController
  skip_before_filter :authenticate_user!

  def user_utils
    render :layout => false
  end
end
