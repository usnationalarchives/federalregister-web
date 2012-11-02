if defined?(VCR)
  VCR.configure do |c|
    c.default_cassette_options = { :record => :new_episodes }
    c.cassette_library_dir = Rails.root.join("spec", "vcr")
    c.hook_into :fakeweb
  end

  VCR.insert_cassette(Rails.env.to_s)
end
