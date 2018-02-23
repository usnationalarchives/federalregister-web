Rails.application.config.middleware.insert_before 0, "Rack::Cors" do
  if SECRETS['omniauth']['oidc_url']
    allow do
      oidc = URI.parse(SECRETS['omniauth']['oidc_url'])
      origins oidc.host
      resource '/my/sign_out', headers: :any, credentials: true, methods: [:get]
    end
  end
end
