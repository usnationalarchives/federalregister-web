class SessionsController < ApplicationController
  skip_before_filter :authenticate_user!

  def new
    session[:redirect_to] = profile_params.delete(:redirect_to)

    redirect_to ["#{Settings.canonical_host}/auth/ofr", profile_url_params].compact.join('?')
  end

  def create
    redirect_url = valid_redirect_url || subscriptions_path 
    session[:redirect_url] = nil

    session[:user_details] = auth_hash["extra"]["raw_info"].merge(
      token: auth_hash["credentials"]["token"]
    )
    SendgridClient.new.remove_from_bounce_list(session[:user_details][:email])
    flash[:success] = "Signed in successfully"

    redirect_to redirect_url
  end

  def destroy
    if request.xhr?
      reset_session
    else
      reset_session #B.C. TODO: Remove this manual session reset once the CORS ajax requests are fixed
      redirect_to SECRETS["omniauth"]["oidc_url"] + "/sign_out?redirect_to=#{URI.escape root_url}"
    end
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  def profile_params
    params.permit(:redirect_to, :jwt)
  end

  def profile_url_params
    profile_params.to_hash.present? ? profile_params.to_hash.map{|k,v| "#{k}=#{v}"}.join('&') : nil
  end

  def valid_redirect_url
    return nil unless session[:redirect_to]

    /\A#{Settings.canonical_host}/.match?(session[:redirect_to]) ? session[:redirect_to] : nil
  end

end
