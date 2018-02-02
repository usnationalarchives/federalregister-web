module OmniauthHelper

  def user_signed_in?
    current_user.present?
  end

  CONFIRMATION_TIME_STUB = ActiveSupport::TimeZone[Time.zone.name].parse("2018-01-01 1am")
  def current_user
    if session[:user_details]
      @current_user ||= User.new(session[:user_details])
      @current_user.id = session[:user_details][:id]
      if session[:user_details][:email_confirmed]
        @current_user.confirmed_at = CONFIRMATION_TIME_STUB
      end
      @current_user
    end
  end

end
