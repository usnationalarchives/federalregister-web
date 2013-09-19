class FRMailer < Devise::Mailer
  include SendGrid
  
  add_template_helper(MailerHelper)
  add_template_helper(AssetHelper)

  layout "mailer/two_col_1_2"

  default :from => "My Federal Register <noreply@mail.federalregister.gov>"

  sendgrid_enable :opentracking, :clicktracking, :ganalytics

  def confirmation_instructions(user)
    @user = user
    @utility_links = [['Manage my subscriptions', subscriptions_url(:utm_campaign => "utility_links", :utm_medium => "email", :utm_source => "federalregister.gov", :utm_content => "manage_subscription")]]
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

  def generic_notification(users, subject, html_content, text_content, category)
    @html_content = html_content
    @text_content = text_content
    @utility_links = [['Manage my subscriptions', subscriptions_url(:utm_campaign => "utility_links", :utm_medium => "email", :utm_source => "federalregister.gov", :utm_content => "manage_subscription")]]

    @highlights = EmailHighlight.pick(2)

    sendgrid_category category
    sendgrid_recipients users.map(&:email)
    sendgrid_substitute "(((email)))", users.map(&:email)
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => category
    
    mail(
      :from => "Federal Register <noreply@mail.federalregister.gov>",
      :subject => subject,
      :to => 'nobody@federalregister.gov' # should use sendgrid_recipients for actual recipient list
    ) do |format|
      format.text { render('generic_notification') }
      format.html { Premailer.new( render('generic_notification'),
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

    def generic_notification
      users =  [User.new(:email => 'name@example.com')]
      email_notification = EmailNotification.find('subscription_management_my_fr_accounts')
      FRMailer.generic_notification(users, email_notification.subject, email_notification.html_content, email_notification.text_content, email_notification.category)
    end
  end

end
