class MailingList::Document < MailingList

  def model
    ::Document
  end

  def deliver!(date, subscriptions, confirmed_emails_by_user_id)
    if subscriptions.present? && has_results?(date)
      results = results_for_date(date)
      presenter = Mailers::TableOfContentsPresenter.new(date, results, self)

      subscriptions.find_in_batches(batch_size: BATCH_SIZE) do |batch_subscriptions|
        batch_emails = batch_subscriptions.map do |subscription|
          confirmed_emails_by_user_id[subscription.user_id.to_s]
        end

        SubscriptionMailer.document_mailing_list(
          presenter,
          batch_subscriptions,
          message_body(subscriptions.count, presenter, batch_subscriptions, batch_emails),
          batch_emails
        ).deliver

        update_delivery_status(batch_subscriptions, date)
        log_delivery(batch_subscriptions.count, results.size)
      end
    else
      log_no_delivery
    end
  end

  private

  # if we're going to send multiple batches of this email, cache the message body
  # otherwise skip this step as it'll be slower
  def message_body(subscription_count, presenter, batch_subscriptions, batch_emails)
    return @message_body if @message_body
    return nil unless subscription_count > BATCH_SIZE

    message = SubscriptionMailer.document_mailing_list(
      presenter,
      batch_subscriptions,
      nil,
      batch_emails
    )
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

  def update_delivery_status(subscriptions, date)
    Subscription.where(id: subscriptions.map(&:id)).update_all(['delivery_count = delivery_count + 1, last_delivered_at = ?, last_issue_delivered = ?', Time.now, date])
  end
end
