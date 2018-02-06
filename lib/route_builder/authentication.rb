module RouteBuilder::Authentication
  def sign_in_url_test(redirect_to=nil, notifications=nil)
    notifications = {info: I18n.t('sessions.sign_in')} unless notifications
    options = {jwt: JwtUtils.encode({notifications: notifications})}

    options.merge!(redirect_to: redirect_to) if redirect_to

    params = options.map{|k,v| "#{k}=#{v}"}.join('&')
    "#{Settings.canonical_host}/auth/sign_in?#{params}"
  end
end
