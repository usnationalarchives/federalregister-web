CarrierWave.configure do |config|
  config.fog_credentials = {
    :aws_access_key_id      => Rails.application.secrets['aws']['access_key_id'],
    :aws_secret_access_key  => Rails.application.secrets['aws']['secret_access_key'],
    :persistent             => false,
    :provider               => 'AWS',       # required
  }
  config.fog_public    = false

  if Rails.env.production?
    config.fog_directory = "my-fr-files.federalregister.gov"
  else
    config.fog_directory = "my-fr-files.fr2.criticaljuncture.org"
  end
end
