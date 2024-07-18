# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << "#{Rails.root}/app/asssets/fonts"

# Add additional assets to the SASS load paths
Rails.application.config.sass.load_paths << "#{Rails.root}/app/asssets/fonts"
Rails.application.config.sass.load_paths << "#{Rails.root}/vendor/asssets/stylesheets"

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += %w(
  vendor.js
  admin/vendor.js

  utilities/modal.js

  print.css
  vendor.css

  mailers/comment_mailer.css
  mailers/common.css
  mailers/fr_mailer.css
  mailers/subscription_mailer.css

  *.eot
  *.svg
  *.ttf
  *.woff

  admin/highlighted_documents.js
  utilities/modal.js

  doc_preview.png

  official_masthead.png
  official_masthead.svg
  public_inspection_masthead.png
  public_inspection_masthead.svg
  reader_aids_masthead.png
  reader_aids_masthead.svg

  blue_header_bg.png
  red_header_bg.png

  search.png
  search.svg

  regulations_dot_gov_logo.png
  regulations_dot_gov_logo_sidebar.png

  swagger.css
)
