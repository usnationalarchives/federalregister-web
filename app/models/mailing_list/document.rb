class MailingList::Document < MailingList
  def self.perform(mailing_list_id, date, options={})
    begin
      find(mailing_list_id).deliver!(date, options)
    rescue StandardError => e
      Rails.logger.warn(e)
      Honeybadger.notify(e, context: {
        mailing_list_id: mailing_list_id,
        date: date,
        options: options
      })
    end
  end

  def model
    ::Document
  end

  def deliver!(date, options={})
    if has_results?(date)
      results = results_for_date(date)

      subscriptions = active_subscriptions
      subscriptions = subscriptions.not_delivered_on(date) unless options[:force_delivery]

      presenter = Mailers::TableOfContentsPresenter.new(date, results, self)

      subscriptions.find_in_batches(batch_size: BATCH_SIZE) do |batch_subscriptions|
        SubscriptionMailer.document_mailing_list(
          presenter,
          batch_subscriptions,
          message_body(subscriptions.count, presenter, batch_subscriptions)
        ).deliver
      end

      update_subscription_counts(subscriptions, date)
      log_delivery(subscriptions.count, results.size)
    else
      log_no_delivery
    end
  end

  private

  # if we're going to send multiple batches of this email, cache the message body
  # otherwise skip this step as it'll be slower
  def message_body(subscription_count, presenter, batch_subscriptions)
    return @message_body if @message_body
    return nil unless subscription_count > BATCH_SIZE

    message = SubscriptionMailer.document_mailing_list(presenter, batch_subscriptions)
    @message_body = {html: message.html_part.body, text: message.text_part.body}
  end

  def has_results?(date)
    model.search_metadata(
      conditions: mailing_list_conditions(date)
    ).count > 0
  end

  def results_for_date(date)
    model.search(
      conditions: mailing_list_conditions(date),
      fields: mailing_list_fields,
      per_page: 1000
    ).to_a
  end

  def mailing_list_conditions(date)
    conditions = parameters[:conditions].present? ? parameters[:conditions] : parameters

    conditions.merge({"publication_date" => {"is" => date}})
  end

  def mailing_list_fields
    [
      :document_number,
    ]
  end
end
