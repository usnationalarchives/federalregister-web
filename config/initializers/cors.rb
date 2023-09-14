# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  if Settings.services.fr.web.oidc_url
    allow do
      oidc = URI.parse(Settings.services.fr.web.oidc_url)
      origins oidc.host
      resource '/sign_out', headers: :any, credentials: true, methods: [:get]
    end
  end
end
