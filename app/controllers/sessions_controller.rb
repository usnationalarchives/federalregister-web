class SessionsController < ApplicationController
  include UserDataPersistor
  skip_before_filter :authenticate_user!

  def new
    session[:redirect_to] = profile_params.delete(:redirect_to)

    redirect_to ["#{Settings.canonical_host}/auth/ofr", profile_url_params].compact.join('?')
  end

  def create
    session[:user_details] = auth_hash["extra"]["raw_info"].merge(
      token: auth_hash["credentials"]["token"],
      id:    auth_hash["uid"]
    )
    cookies["expect_signed_in"] = "1"
    SendgridClient.new.remove_from_bounce_list(session[:user_details][:email])

    message, redirect_location = persist_user_data
    flash[:notice] = message[:notice] if message[:notice]
    flash[:warning] = message[:warning] if message[:warning]

    unless message[:notice] || message[:warning]
      flash[:success] = "Signed in successfully"
    end

    session[:redirect_url] = nil
    redirect_to valid_redirect_url || redirect_location
  end

  def destroy
    if request.xhr?
      reset_session
    else
      reset_session #B.C. TODO: Remove this manual session reset once the CORS ajax requests are fixed
      cookies["expect_signed_in"] = "0"
      redirect_to SECRETS["omniauth"]["oidc_url"] + "/sign_out?redirect_to=#{URI.escape root_url}"
    end
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  DEFAULT_REDIRECTION_MESSAGE = I18n.t('sessions.sign_in')
  def profile_params
    params.permit(:redirect_to, :jwt).tap do |p_params|
      unless p_params[:jwt].present?
        p_params[:jwt] = JwtUtils.encode(
          {notifications: {info: DEFAULT_REDIRECTION_MESSAGE}}
        )
      end
    end
  end

  def profile_url_params
    profile_params.to_hash.present? ? profile_params.to_hash.map{|k,v| "#{k}=#{v}"}.join('&') : nil
  end

  def valid_redirect_url
    return nil unless session[:redirect_to]

    /\A#{Settings.canonical_host}/.match(session[:redirect_to]) ? session[:redirect_to] : nil
  end

end
