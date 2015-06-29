if Settings.browser_sync && Settings.browser_sync.enabled
  asset_paths = Rails.application.config.assets.paths
  stylesheet_paths = asset_paths.select do |p|
    p.include?('stylesheets') || p.include?('fonts')
  end

  json = {stylesheets: stylesheet_paths}.to_json

  File.open(File.join(Rails.root, '.asset_paths.json'), 'w+') do |file|
    file.write json
  end
end
