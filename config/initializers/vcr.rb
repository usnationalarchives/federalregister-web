if defined?(VCR) && Rails.env.test?
  VCR.configure do |c|
    c.default_cassette_options = { :record => :new_episodes }
    c.ignore_hosts '127.0.0.1', 'localhost'
    c.cassette_library_dir = Rails.root.join("spec", "vcr")
    c.hook_into :fakeweb

    c.filter_sensitive_data('<API_KEY>') { SECRETS['data_dot_gov']['api_key'] }
    c.filter_sensitive_data('<DEMO_KEY>') { 'DEMO_KEY' }
    c.debug_logger = File.open(Rails.root.join("log", Rails.env, "vcr.log"), 'w')
  end

  VCR.insert_cassette(Rails.env.to_s)
end

if defined?(VCR) && Rails.env.development? && Settings.vcr.enabled
  VCR.configure do |c|
    c.default_cassette_options = { :record => :new_episodes }

    c.ignore_hosts *Settings.vcr.ignore_hosts
    c.cassette_library_dir = Rails.root.join(Settings.vcr.library_dir).to_s

    c.hook_into :fakeweb

    if Settings.vcr.log_output
      c.debug_logger = File.open(Rails.root.join("log", "#{Settings.vcr.cassette}.vcr.log"), 'w')
    end

    c.default_cassette_options = {
      re_record_interval: Settings.vcr.re_record_interval.days
    }

    ignored_paths = Settings.vcr.ignore_paths.map{|p| Regexp.new(p)}

    c.before_playback do |interaction|
      interaction.ignore! if interaction.response.status.code >= 500

      u = URI.parse(interaction.request.uri)
      ignored_paths.each do |path|
        interaction.ignore! if u.path =~ path
      end
    end

    c.before_record do |interaction|
      interaction.ignore! if interaction.response.status.code >= 500

      u = URI.parse(interaction.request.uri)
      ignored_paths.each do |path|
        interaction.ignore! if u.path =~ path
      end
    end
  end
end
