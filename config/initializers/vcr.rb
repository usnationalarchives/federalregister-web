if defined?(VCR)
  VCR.configure do |c|
    c.default_cassette_options = { :record => :once }
    c.cassette_library_dir = Rails.root.join("spec", "vcr")
    c.hook_into :fakeweb

    c.filter_sensitive_data('DEMO_KEY') { SECRETS['data_dot_gov']['api_key'] || 'DEMO_KEY' }
    c.debug_logger = File.open(Rails.root.join("log", "vcr.log"), 'w')
  end

  VCR.insert_cassette(Rails.env.to_s)
end
