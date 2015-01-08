class MailingList::PublicInspectionDocument < MailingList
  def model
    FederalRegister::PublicInspectionDocument
  end

  def deliver!(document_numbers, options = {})
    return if document_numbers.empty?

    results = results_for_document_numbers(document_numbers)

    unless results.empty?
      subscriptions = active_subscriptions

      subscriptions.find_in_batches(:batch_size => 1000) do |batch_subscriptions|
        SubscriptionMailer.public_inspection_document_mailing_list(self, results, batch_subscriptions).deliver
      end
      Rails.logger.info("delivered mailing_lists/#{id} to #{subscriptions.count} subscribers (#{results.size} public inspection documents})")
    end
  end

  private

  def results_for_document_numbers(document_numbers)
    model.search(
      :conditions => parameters.merge({:document_numbers => document_numbers}),
      :fields => [
        :agencies,
        :document_number,
        :filed_at,
        :publication_date,
        :title,
        :toc_subject,
        :toc_doc,
        :type
      ],
      :per_page => 1000
    ).to_a
  end
end
