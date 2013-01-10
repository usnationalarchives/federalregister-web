class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)

    sign_in_or_redirect(@user, "facebook")
  end

  def twitter
    @user = User.find_for_twitter_oauth(request.env["omniauth.auth"], current_user)
    
    sign_in_or_redirect(@user, "twitter")
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  private

  def sign_in_or_redirect(user, auth_type)
    if user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => auth_type.capitalize
      sign_in_and_redirect user, :event => :authentication
    else
      session["devise.#{auth_type}_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end
