module OmniauthHelper

  def user_signed_in?
    current_user.present?
  end

  def current_user
    if session[:user_details]
      User.current = UserDecorator.decorate(
        User.new(session[:user_details])
      )

      User.current
    end
  end

  def refresh_current_user
    begin
      current_user.refresh
    rescue User::StaleOauthToken
      redirect_to sign_in_url
    end
  end
end
