class SubscriptionMailer < ActionMailer::Base
  include SendGrid

  add_template_helper(MailerHelper)
  add_template_helper(BootstrapHelper)
  add_template_helper(FrBoxHelper)
  add_template_helper(DocumentIssueHelper)
  add_template_helper(IconHelper)

  default :from => "Federal Register Subscriptions <subscriptions@mail.federalregister.gov>"

  sendgrid_enable :opentracking, :clicktracking, :ganalytics

  def subscription_confirmation(subscription)
    @subscription = subscription
    @utility_links = []
    @highlights = EmailHighlight.highlights_with_selected(1, 'manage_subscriptions_via_my_fr')

    sendgrid_category "Subscription Confirmation"
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'subscription confirmation'

    mail(
      :to => subscription.email,
      :subject => "[FR] #{subscription.mailing_list.title}"
    ) do |format|
      format.text { render('subscription_confirmation') }
      format.html { Premailer.new( render('subscription_confirmation', :layout => "mailer/two_col_1_2"),
                                   :with_html_string => true,
                                   :warn_level => Premailer::Warnings::SAFE).to_inline_css }
    end
  end

  def unsubscribe_notice(subscription)
    @subscription = subscription
    @utility_links = []
    @highlights = EmailHighlight.highlights_with_selected(1, 'manage_subscriptions_via_my_fr')

    sendgrid_category "Subscription Unsubscribe"
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'subscription unsubscribe'

    mail(
      :to => subscription.email,
      :subject => "[FR] #{subscription.mailing_list.title}"
    ) do |format|
      format.text { render('unsubscribe_notice') }
      format.html { Premailer.new( render('unsubscribe_notice', :layout => "mailer/two_col_1_2"),
                                   :with_html_string => true,
                                   :warn_level => Premailer::Warnings::SAFE).to_inline_css }
    end
  end

  # uses sendgrid_recipients for actual recipient list
  def public_inspection_document_mailing_list(presenters, subscriptions, message_body=nil)
    @presenter = presenters.fetch(:presenter)
    @special_filings_presenter = presenters.fetch(:special_filings_presenter, nil)
    @regular_filings_presenter = presenters.fetch(:regular_filings_presenter, nil)

    @mailing_list_title = @special_filings_presenter ? @special_filings_presenter.mailing_list_title : @regular_filings_presenter.mailing_list_title
    @total_document_count = (@special_filings_presenter.try(:documents).try(:count) || 0) +
      (@regular_filings_presenter.try(:documents).try(:count) || 0)

    @utility_links = [['Manage my subscriptions', subscriptions_url(:utm_campaign => "utility_links", :utm_medium => "email", :utm_source => "federalregister.gov", :utm_content => "manage_subscription")],
                      ["Unsubscribe from these results", unsubscribe_subscription_url('(((token)))')]]

    @highlights = EmailHighlight.pick(2)

    sendgrid_category "PI Subscription"
    sendgrid_recipients subscriptions.map(&:email)
    sendgrid_substitute "(((token)))", subscriptions.map(&:token)
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'pi subscription mailing list'

    subject = "[FR] #{@mailing_list_title}"
    to = 'nobody@federalregister.gov'

    # we support the passing of 'pre-compiled' message bodies
    # all dynamic content is set via the sendgrid headers
    # this allows us to skip the generation of the body multiple times
    # for the same mailing list when sending in batches
    if message_body
      mailer = mail(
        subject: subject,
        to: to
      ) do |format|
        format.text {}
        format.html {}
      end

      mailer.html_part.body = message_body[:html].to_s
      mailer.text_part.body = message_body[:text].to_s

      mailer
    else
      formats = {
        text: Proc.new { render('public_inspection_document_mailing_list') },
        html: Proc.new {
          Premailer.new(
            render('public_inspection_document_mailing_list', layout: "mailer/two_col_1_2"),
            with_html_string: true,
            warn_level: Premailer::Warnings::SAFE
          ).to_inline_css
        }
      }
      generate_mailer(subject, to, formats)
    end
  end

  # uses sendgrid_recipients for actual recipient list
  def document_mailing_list(presenter, subscriptions, message_body=nil)
    @presenter = presenter

    @utility_links = [['Manage my subscriptions', subscriptions_url(:utm_campaign => "utility_links", :utm_medium => "email", :utm_source => "federalregister.gov", :utm_content => "manage_subscription")],
                      ["Unsubscribe from these results", unsubscribe_subscription_url('(((token)))')]]

    @highlights = EmailHighlight.pick(2)

    sendgrid_category "Subscription"
    sendgrid_recipients subscriptions.map(&:email)
    sendgrid_substitute "(((token)))", subscriptions.map(&:token)
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'subscription mailing list'

    subject = "[FR] #{@presenter.mailing_list_title}"
    to = 'nobody@federalregister.gov'

    # we support the passing of 'pre-compiled' message bodies
    # all dynamic content is set via the sendgrid headers
    # this allows us to skip the generation of the body multiple times
    # for the same mailing list when sending in batches
    if message_body
      formats = {
        text: Proc.new { },
        html: Proc.new { }
      }

      mailer = generate_mailer(subject, to, formats)

      mailer.html_part.body = message_body[:html].to_s
      mailer.text_part.body = message_body[:text].to_s

      mailer
    else
      formats = {
        text: Proc.new { render('document_mailing_list') },
        html: Proc.new {
          Premailer.new(
            render('document_mailing_list', layout: "mailer/two_col_1_2"),
            with_html_string: true,
            warn_level: Premailer::Warnings::SAFE
          ).to_inline_css
        }
      }
      generate_mailer(subject, to, formats)
    end
  end

  def generate_mailer(subject, to, formats)
    mail(
      subject: subject,
      to: to
    ) do |format|
      format.text { formats[:text].call }
      format.html { formats[:html].call }
    end
  end

  class Preview < MailView
    def subscription_confirmation
      subscription = Subscription.find(2)
      SubscriptionMailer.subscription_confirmation(subscription)
    end

    def unsubscribe_notice
      subscription = Subscription.find(2)
      SubscriptionMailer.unsubscribe_notice(subscription)
    end

    def document_mailing_list
      date = Date.today
      mailing_list = MailingList.find(2)
      subscriptions = mailing_list.subscriptions
      results = mailing_list.send(:results_for_date, date)
      presenter = Mailers::TableOfContentsPresenter.new(date, results, mailing_list)

      message = SubscriptionMailer.document_mailing_list(presenter, subscriptions)
      message_body = {html: message.html_part.body, text: message.text_part.body}

      SubscriptionMailer.document_mailing_list(presenter, subscriptions, message_body)
    end

    def public_inspection_document_mailing_list
      date = Date.today
      mailing_list = MailingList.find(22251)
      subscriptions = mailing_list.subscriptions
      document_numbers = PublicInspectionDocument.available_on(date).map(&:document_number)

      results = mailing_list.send(:results_for_document_numbers, document_numbers).group_by(&:filing_type)
      special_filing_results = results["special"]
      regular_filing_results = results["regular"]

      presenter = PublicInspectionIssuePresenter.new(date)
      regular_filings_presenter = regular_filing_results ? Mailers::PublicInspectionRegularFilingsPresenter.new(date, regular_filing_results, mailing_list) : nil
      special_filings_presenter = special_filing_results ? Mailers::PublicInspectionSpecialFilingsPresenter.new(date, special_filing_results, mailing_list) : nil

      presenters = {
        presenter: presenter,
        regular_filings_presenter: regular_filings_presenter,
        special_filings_presenter: special_filings_presenter
      }

      message = SubscriptionMailer.public_inspection_document_mailing_list(presenters, subscriptions)
      message_body = {html: message.html_part.body, text: message.text_part.body}

      SubscriptionMailer.public_inspection_document_mailing_list(presenters, subscriptions, message_body)
    end
  end
end
