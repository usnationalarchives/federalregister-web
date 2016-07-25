class MailingList::PublicInspectionDocument < MailingList
  def self.perform(mailing_list_id, date, document_numbers, options={})
    begin
      find(mailing_list_id).deliver!(date, document_numbers, options)
    rescue StandardError => e
      Rails.logger.warn(e)
      Honeybadger.notify(e, context: {
        mailing_list_id: mailing_list_id,
        date: date,
        document_numbers: document_numbers,
        options: options
      })
    end
  end

  def model
    ::PublicInspectionDocument
  end

  def deliver!(date, document_numbers, options={})
    if has_results?(document_numbers)

      results = results_for_document_numbers(document_numbers).group_by(&:filing_type)
      subscriptions = active_subscriptions

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
        SubscriptionMailer.public_inspection_document_mailing_list(
          presenters,
          batch_subscriptions,
          message_body(subscriptions.count, presenters, batch_subscriptions)
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
  def message_body(subscription_count, presenters, batch_subscriptions)
    return @message_body if @message_body
    return nil unless subscription_count > BATCH_SIZE

    message = SubscriptionMailer.public_inspection_document_mailing_list(
      presenters,
      batch_subscriptions
    )
    @message_body = {html: message.html_part.body, text: message.text_part.body}
  end

  def has_results?(document_numbers)
    model.search_metadata(
      conditions: mailing_list_conditions(document_numbers)
    ).count > 0
  end

  def results_for_document_numbers(document_numbers)
    model.search(
      conditions: mailing_list_conditions(document_numbers),
      fields: mailing_list_fields,
      per_page: 1000
    ).to_a
  end

  def mailing_list_conditions(document_numbers)
    conditions = parameters[:conditions].present? ? parameters[:conditions] : parameters

    conditions.merge({"document_numbers" => document_numbers})
  end

  def mailing_list_fields
    [
      :agencies,
      :document_number,
      :filed_at,
      :filing_type,
      :publication_date,
      :title,
      :toc_subject,
      :toc_doc,
      :type
    ]
  end
end
