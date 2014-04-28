RegulationsDotGov::Client.api_key = SECRETS['data_dot_gov']['api_key'] || 'DEMO_KEY'

if Rails.env.development? || Rails.env.test?
  RegulationsDotGov::Client.override_base_uri('http://api.data.gov/TEST/regulations/v3/')
end

if Rails.env.staging? || Rails.env.production?
  RegulationsDotGov::Client.override_base_uri('http://api.data.gov/regulations/v3/')
end
