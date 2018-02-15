Rails.application.config.middleware.insert_before 0, "Rack::Cors" do
  if SECRETS['omniauth']['oidc_url']
    allow do
      oidc = URI.parse(SECRETS['omniauth']['oidc_url'])
      origins "#{oidc.host}:#{oidc.port}"
      resource '/sign_out', headers: :any, credentials: true, methods: [:get]
    end
  end

  allow do
    origins '*'
    resource '/public/*', :headers => :any, :methods => :get
  end
end
