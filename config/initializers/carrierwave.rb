AMAZON_CONFIG = YAML::load(File.open(Rails.root.join('config', 'amazon.yml')))

CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',       # required
    :aws_access_key_id      => AMAZON_CONFIG['access_key_id'],
    :aws_secret_access_key  => AMAZON_CONFIG['secret_access_key']
  }
  config.fog_public    = false

  if Rails.env.production?
    config.fog_directory = "my-fr-files.federalregister.gov"
  else
    config.fog_directory = "my-fr-files.fr2.criticaljuncture.org"
  end
end
