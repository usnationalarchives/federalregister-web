case Rails.env
when 'development'
  # FederalRegister::Base.override_base_uri 'http://api.fr2.local:8080/v1'
when 'staging'
  FederalRegister::Base.override_base_uri 'http://api.fr2.criticaljuncture.org/v1'
when 'production'
end

