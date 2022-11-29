class DocumentMailer < ActionMailer::Base
  include SendGrid

  helper(MailerHelper)
  helper(TextHelper)

  sendgrid_enable :opentracking, :clicktracking, :ganalytics

  def email_a_friend(entry_email)
    @entry_email = entry_email
    @document = DocumentDecorator.decorate(
      Document.find(entry_email.document_number)
    )

    @utility_links = []
    @highlights = EmailHighlight.pick(2)

    sendgrid_category "Email a Friend"
    sendgrid_recipients entry_email.all_recipient_emails
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'email a friend'

    mail(
      subject: "[FR] #{@entry_email.sender} has sent you '#{@document.title}'",
      to: 'email-a-friend@federalregister.gov', #use sendgrid_recipients above
      from: 'FederalRegister.gov <no-reply@mail.federalregister.gov>',
      reply_to: @entry_email.sender
    ) do |format|
      format.text { render('email_a_friend') }
      format.html {
        render('email_a_friend', layout: "mailer/two_col_1_2", locals: {legal: true})
      }
    end
  end

  class Preview < MailView
    def email_a_friend
      entry_email = EntryEmail.last
      entry_email.sender = 'no-reply@mail.federalregister.gov'
      entry_email.recipients = ['andrew@example.com', 'rich@example.com', 'brandon@example.com']
      entry_email.message = "Hello old friends, you might find this interesting..."
      DocumentMailer.email_a_friend(entry_email)
    end
  end
end
