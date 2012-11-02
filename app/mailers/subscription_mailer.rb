class SubscriptionMailer < ActionMailer::Base
  include SendGrid

  default :from => "Federal Register Subscriptions <subscriptions@mail.federalregister.gov>"
  
  sendgrid_enable :opentracking, :clicktracking, :ganalytics
  def subscription_confirmation(subscription)
    @subscription = subscription

    sendgrid_category "Subscription Confirmation"
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'subscription confirmation'
    
    mail(
      :to => subscription.email,
      :subject => "[FR] #{subscription.mailing_list.title}"
    )
  end

  def unsubscribe_notice(subscription)
    @subscription = subscription
    
    sendgrid_category "Subscription Unsubscribe"
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'subscription unsubscribe'
    
    mail(
      :to => subscription.email,
      :subject => "[FR] #{subscription.mailing_list.title}"
    )
  end
  
  def public_inspection_document_mailing_list(mailing_list, results, subscriptions)
    @mailing_list = mailing_list
    @results = ArticleDecorator.decorate(results.to_a)
    toc = TableOfContentsPresenter.new(results)
    @agencies = toc.agencies
    @articles_without_agencies = toc.articles_without_agencies

    sendgrid_category "PI Subscription"
    sendgrid_recipients subscriptions.map(&:email)
    sendgrid_substitute "(((token)))", subscriptions.map(&:token)
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'pi subscription mailing list'
    
    mail(
      :subject => "[FR] #{mailing_list.title}",
      :to => 'nobody@federalregister.gov' # should use sendgrid_recipients for actual recipient list
    )
  end

  def entry_mailing_list(mailing_list, results, subscriptions)
    @mailing_list = mailing_list
    @results = ArticleDecorator.decorate(results.to_a)
    toc = TableOfContentsPresenter.new(results)
    @agencies = toc.agencies
    @articles_without_agencies = toc.articles_without_agencies

    sendgrid_category "Subscription"
    sendgrid_recipients subscriptions.map(&:email)
    sendgrid_substitute "(((token)))", subscriptions.map(&:token)
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'subscription mailing list'
    
    toc = TableOfContentsPresenter.new(results)
    
    mail(
      :subject => "[FR] #{mailing_list.title}",
      :to =>  'nobody@federalregister.gov' # should use sendgrid_recipients for actual recipient list
    )
  end
end