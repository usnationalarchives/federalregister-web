class ApplicationController < ActionController::Base
  include Userstamp

  protect_from_forgery

  before_filter :authenticate_user!
  before_filter :decorate_current_user

  def decorate_current_user
    @current_user = UserDecorator.decorate(current_user) if current_user
  end
  
end
