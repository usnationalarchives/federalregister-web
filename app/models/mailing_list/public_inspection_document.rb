class MailingList::PublicInspectionDocument < MailingList

  def model
    ::PublicInspectionDocument
  end

  def deliver_now(date, subscriptions, confirmed_emails_by_user_id, document_numbers, options={})
    subscriptions = options["force_delivery"] ? subscriptions : subscriptions.not_delivered_for(document_numbers)

    if subscriptions.present? && has_results?(document_numbers)

      results = results_for_document_numbers(document_numbers).group_by(&:filing_type)

      special_filing_results = results["special"]
      regular_filing_results = results["regular"]

      presenter = PublicInspectionIssuePresenter.new(date)
      regular_filings_presenter = regular_filing_results ? Mailers::PublicInspectionRegularFilingsPresenter.new(date, regular_filing_results, self) : nil
      special_filings_presenter = special_filing_results ? Mailers::PublicInspectionSpecialFilingsPresenter.new(date, special_filing_results, self) : nil

      presenters = {
        presenter: presenter,
        regular_filings_presenter: regular_filings_presenter,
        special_filings_presenter: special_filings_presenter
      }

      subscriptions.find_in_batches(batch_size: BATCH_SIZE) do |batch_subscriptions|
        batch_emails = batch_subscriptions.map do |subscription|
          confirmed_emails_by_user_id[subscription.user_id.to_s]
        end

        SubscriptionMailer.public_inspection_document_mailing_list(
          presenters,
          batch_subscriptions,
          message_body(subscriptions.count, presenters, batch_subscriptions, batch_emails),
          batch_emails
        ).deliver_now

        update_delivery_status(batch_subscriptions, date, document_numbers)
        log_delivery(batch_subscriptions.count, results.size)
      end
    else
      log_no_delivery
    end
  end


  private

  # if we're going to send multiple batches of this email, cache the message body
  # otherwise skip this step as it'll be slower
  def message_body(subscription_count, presenters, batch_subscriptions, batch_emails)
    return @message_body if @message_body
    return nil unless subscription_count > BATCH_SIZE

    message = SubscriptionMailer.public_inspection_document_mailing_list(
      presenters,
      batch_subscriptions,
      nil,
      batch_emails
    )
    @message_body = {html: message.html_part.body, text: message.text_part.body}
  end

  def has_results?(document_numbers)
    model.search_metadata(
      conditions: mailing_list_conditions(document_numbers)
    ).count > 0
  end

  def results_for_document_numbers(document_numbers)
    document_numbers.in_groups_of(130,false).flat_map do |batch_ids|
      model.search(
        conditions: mailing_list_conditions(batch_ids),
        fields: mailing_list_fields,
        per_page: 1000
      ).to_a
    end
  end

  def mailing_list_conditions(document_numbers)
    conditions = parameters[:conditions].present? ? parameters[:conditions] : parameters

    conditions.merge({"document_numbers" => document_numbers})
  end

  def mailing_list_fields
    [
      :document_number,
      :filing_type,
    ]
  end

  def update_delivery_status(subscriptions, date, document_numbers)
    Subscription.where(id: subscriptions.map(&:id)).update_all(
      ['delivery_count = delivery_count + 1, last_delivered_at = ?, last_issue_delivered = ?, last_documents_delivered_hash = ?',
        DateTime.now.utc.to_s(:db), date.to_date.to_s(:db),
        Digest::MD5.hexdigest( Array(document_numbers).sort.join(',') )
      ])
  end
end
