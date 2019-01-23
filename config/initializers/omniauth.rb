if Rails.application.secrets["omniauth"]["oidc_url"]
  oidc_uri = URI.parse(Rails.application.secrets["omniauth"]["oidc_url"])
  if oidc_uri.scheme == "http"
    WebFinger.url_builder = URI::HTTP
    SWD.url_builder = URI::HTTP
  end

  SETUP_PROC = lambda do |env|
    request = Rack::Request.new(env)
    env['omniauth.strategy'].options["jwt"] = request.params["jwt"]
  end

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :openid_connect, {
      name: :ofr,
      scope: [:openid, :email, :profile],
      response_type: :code,
      discovery: true,
      issuer: Rails.application.secrets["omniauth"]["oidc_url"],
      client_options: {
        port: oidc_uri.port,
        scheme: oidc_uri.scheme,
        host: oidc_uri.host,
        identifier: Rails.application.secrets["omniauth"]["oidc_application_id"],
        secret: Rails.application.secrets["omniauth"]["oidc_secret"],
        redirect_uri: Rails.application.secrets["omniauth"]["oidc_redirect_url"],
      },
      setup: SETUP_PROC
    }
  end
end
