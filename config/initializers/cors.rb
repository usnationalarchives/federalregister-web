Rails.application.config.middleware.insert_before 0, Rack::Cors do
  if Rails.application.secrets[:omniauth][:oidc_url]
    allow do
      oidc = URI.parse(Rails.application.secrets[:omniauth][:oidc_url])
      origins oidc.host
      resource '/sign_out', headers: :any, credentials: true, methods: [:get]
    end
  end
end
