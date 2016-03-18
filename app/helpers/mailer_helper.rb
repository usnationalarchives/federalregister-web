module MailerHelper
  include RouteBuilder::Documents

  def add_css_file_to_mailer(css_path, options={})
    asset_path = options.fetch(:mailer, true) ? "mailers/#{css_path}" : css_path

    content_for :mailer_template_css, Rails.application.assets.find_asset(asset_path)
  end

  def mailer_asset_url(asset)
    base_url =  ActionMailer::Base.default_url_options[:protocol] +
                  ActionMailer::Base.default_url_options[:host]

    asset_url = base_url + asset_path(asset)
  end

end
