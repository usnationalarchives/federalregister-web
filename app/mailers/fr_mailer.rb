class FRMailer < Devise::Mailer
  include SendGrid
  
  add_template_helper(MailerHelper)
  add_template_helper(AssetHelper)

  layout "mailer/two_col_1_2"

  default :from => "My Federal Register <noreply@mail.federalregister.gov>"

  sendgrid_enable :opentracking, :clicktracking, :ganalytics

  def confirmation_instructions(user)
    @user = user
    @utility_links = [['Manage my subscriptions', subscriptions_url()]]
    @highlights = EmailHighlight.pick(2)

    sendgrid_category "MyFR Email Address Confirmation"
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'MyFR email confirmation'

    mail(
      :to => user.email,
      :subject => "[FR] MyFR Email Confirmation"
    ) do |format|
      format.text { render('confirmation_instructions') }
      format.html { Premailer.new( render('confirmation_instructions'),
                                   :with_html_string => true,
                                   :warn_level => Premailer::Warnings::SAFE).to_inline_css }
    end
  end

  def reset_password_instructions(user)
    @user = user
    @utility_links = []
    @highlights = EmailHighlight.pick(2)

    sendgrid_category "MyFR Reset Password Instructions"
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'MyFR reset password'

    mail(
      :to => user.email,
      :subject => "[FR] MyFR Reset Password Instructions"
    ) do |format|
      format.text { render('reset_password_instructions') }
      format.html { Premailer.new( render('reset_password_instructions'),
                                   :with_html_string => true,
                                   :warn_level => Premailer::Warnings::SAFE).to_inline_css }
    end
  end

  class Preview < MailView
    def confirmation_instructions
      user = User.new(:email => 'name@example.com',
                      :confirmation_token => '123456789')
      user.created_at = Time.now
      FRMailer.confirmation_instructions(user)
    end

    def reset_password_instructions
      user = User.new(:email => 'name@example.com',
                      :reset_password_token => '123456789')
      user.created_at = Time.now
      FRMailer.reset_password_instructions(user)
    end
  end

end
