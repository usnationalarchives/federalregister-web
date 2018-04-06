module OmniauthHelper

  def user_signed_in?
    current_user.present?
  end

  def current_user
    return User.current if User.current

    if session[:user_details]
      User.current = UserDecorator.decorate(
        User.new(session[:user_details])
      )

      User.current
    end
  end

  def refresh_current_user
    begin
      session[:user_details] = current_user.refresh
      cookies[:user_data] = {email: current_user.email}.to_json
    rescue User::StaleOauthToken
      redirect_to sign_in_url
    end
  end
end
