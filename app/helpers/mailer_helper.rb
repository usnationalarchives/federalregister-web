module MailerHelper
  def add_css_file_to_mailer(mailer_path)
    content_for :mailer_template_css, Rails.application.assets.find_asset("mailers/#{mailer_path}")
  end
end
