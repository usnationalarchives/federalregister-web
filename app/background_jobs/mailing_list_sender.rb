class MailingListSender
  extend Memoist

  extend Resque::Plugins::Retry
  @queue = :subscriptions
  @retry_limit = 3
  @retry_delay = 60

  def self.perform(mailing_list_id, date, options={})
    new(mailing_list_id, date, options).perform
  end

  def initialize(mailing_list_id, date, options={})
    @mailing_list_id = mailing_list_id
    @date            = date
    @options         = options
  end

  def perform
    ActiveRecord::Base.clear_active_connections!

    begin
      if options["document_numbers"]
        mailing_list.deliver_now(
          date,
          active_and_confirmed_subscriptions,
          confirmed_emails_by_user_id,
          options["document_numbers"]
        )
      else
        mailing_list.deliver_now(
          date,
          active_and_confirmed_subscriptions,
          confirmed_emails_by_user_id
        )
      end
    rescue StandardError => e
      Rails.logger.warn(e)
      Honeybadger.notify(e, context: {
        mailing_list_id: mailing_list_id,
        date:            date,
        options:         options
      })
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
