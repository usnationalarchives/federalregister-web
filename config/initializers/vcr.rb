if defined?(VCR) && Rails.env.test?
  VCR.configure do |c|
    c.default_cassette_options = { :record => :new_episodes }
    c.ignore_hosts '127.0.0.1', 'localhost'
    c.cassette_library_dir = Rails.root.join("spec", "vcr")
    c.hook_into :fakeweb

    c.filter_sensitive_data('<API_KEY>') { SECRETS['data_dot_gov']['api_key'] }
    c.filter_sensitive_data('<DEMO_KEY>') { 'DEMO_KEY' }
    c.debug_logger = File.open(Rails.root.join("log", "vcr.log"), 'w')
  end

  VCR.insert_cassette(Rails.env.to_s)
end
