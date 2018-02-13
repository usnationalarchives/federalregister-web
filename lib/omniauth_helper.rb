module OmniauthHelper

  def user_signed_in?
    current_user.present?
  end

  def current_user
    if session[:user_details]
      @current_user ||= User.new(session[:user_details])
      UserDecorator.decorate(@current_user)
    end
  end

end
