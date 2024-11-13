class MailingListSender
  extend Memoist
  include Sidekiq::Worker

  sidekiq_options :queue => :subscriptions, :retry => 3
  sidekiq_retry_in do |count|
    60
  end
  sidekiq_retries_exhausted do |msg, ex|
    Honeybadger.notify(ex, force: true)
  end
  
  MAX_RETRIES = 1
  def perform(mailing_list_id, date, options={})
    @mailing_list_id = mailing_list_id
    @date            = date
    @options         = options

    ActiveRecord::Base.clear_active_connections!

    retry_count = 0
    begin
      if options["document_numbers"]
        mailing_list.deliver_now(
          date,
          active_and_confirmed_subscriptions,
          confirmed_emails_by_user_id,
          options
        )
      else
        mailing_list.deliver_now(
          date,
          active_and_confirmed_subscriptions,
          confirmed_emails_by_user_id
        )
      end
    rescue MailingList::PublicInspectionDocument::MissingPublicInspectionMailingApiResults => e
      if retry_count < MAX_RETRIES
        retry_count += 1
        sleep(0.5)
        retry
      else
        Honeybadger.context({
          date:            date,
          mailing_list_id: mailing_list_id,
          options:         options,
        }) { raise e }
      end
    rescue StandardError => e
      Rails.logger.warn(e)
      Honeybadger.notify(e, context: {
        mailing_list_id: mailing_list_id,
        date:            date,
        options:         options
      })
      raise e
    end
  end

  private

  attr_reader :mailing_list_id, :date, :options

  def active_and_confirmed_subscriptions
    mailing_list.
      active_subscriptions.
      where(user_id: confirmed_emails_by_user_id.keys)
  end

  def confirmed_emails_by_user_id
    Ofr::UserEmailResultSet.
      get_user_emails(mailing_list.active_subscriptions.pluck(:user_id).uniq)
  end
  memoize :confirmed_emails_by_user_id

  def mailing_list
    MailingList.find(mailing_list_id)
  end
  memoize :mailing_list

end
