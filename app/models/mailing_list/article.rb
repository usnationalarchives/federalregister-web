class MailingList::Article < MailingList
  def model
    FederalRegister::Article
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
  end

  private

  def results_for_date(date)
    model.search(
      :conditions => parameters.merge({:publication_date => {:is => date}}),
      :fields => [
        :abstract,
        :agencies,
        :comments_close_on,
        :document_number,
        :publication_date,
        :raw_text_url,
        :title,
        :toc_subject,
        :toc_doc,
        :type,
      ],
      :per_page => 1000
    ).to_a
  end
end
