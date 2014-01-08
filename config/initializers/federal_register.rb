case Rails.env
when 'development', 'test'
  FederalRegister::Base.override_base_uri 'http://127.0.0.1:8080/api/v1'
when 'staging'
  FederalRegister::Base.override_base_uri 'http://api.fr2.criticaljuncture.org/v1'
when 'production'
end

