# autoload any .rb file under lib/base_extensions
Dir.glob("#{Rails.root}/lib/base_extensions/*.rb").each do |file|
  require file
end
