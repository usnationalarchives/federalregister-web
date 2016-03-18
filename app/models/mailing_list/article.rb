class MailingList::Article < MailingList
  def model
    Document
  end

  def deliver!(date, options = {})
    results = results_for_date(date)

    unless results.empty?
      subscriptions = active_subscriptions
      subscriptions = subscriptions.not_delivered_on(date) unless options[:force_delivery]

      subscriptions.find_in_batches(:batch_size => 1000) do |batch_subscriptions|
        SubscriptionMailer.entry_mailing_list(self, results, batch_subscriptions).deliver
      end
      subscriptions.update_all(['delivery_count = delivery_count + 1, last_delivered_at = ?, last_issue_delivered = ?', Time.now, date])

      Rails.logger.info("delivered mailing_lists/#{id} to #{subscriptions.count} subscribers (#{results.size} articles})")
    end

    Rails.logger.info("[#{Time.now.in_time_zone}] did not deliver mailing_lists/#{id} (#{title}) for published documents")
  end

  private

  def results_for_date(date)
    model.search(
      conditions: parameters.merge({"publication_date" => {"is" => date}}),
      fields: [
        :agencies,
        :citation,
        :document_number,
        :end_page,
        :html_url,
        :pdf_url,
        :publication_date,
        :start_page,
        :title
      ],
      per_page: 1000
    ).to_a
  end
end
