namespace :mailing_lists do
  namespace :documents do
    desc "Enqueue the document mailing lists for a given day"
    task :deliver, [:date] => :environment do |t, args|
      date = Date.parse(args[:date])
      DocumentSubscriptionQueuePopulator.perfom(date)
    end

    desc "renames MailingList::Article to MailingList::Document"
    task :rename_article_to_document => :environment do
      MailingList.connection.execute("UPDATE mailing_lists
        SET mailing_lists.type = 'MailingList::Document'
        WHERE mailing_lists.type = 'MailingList::Article'")
    end
  end

  namespace :public_inspection do
    desc "Enqueue the PI mailing lists for the specified documents"
    task :deliver, [:date, :document_numbers] => :environment do |t, args|
      date = args[:date]
      document_numbers = args[:document_numbers].split(',')
      PublicInspectionDocumentSubscriptionQueuePopulator.perform(date, document_numbers)
    end
  end

  desc "recalculate active subscriptions for this environment"
  task :recalculate_counts => :environment do
    MailingList.connection.execute("UPDATE mailing_lists SET active_subscriptions_count = 0")
    MailingList.connection.execute("UPDATE mailing_lists,
          (
           SELECT mailing_list_id, COUNT(subscriptions.id) AS count
           FROM subscriptions
           WHERE subscriptions.environment = '#{Rails.env}'
             AND subscriptions.confirmed_at IS NOT NULL
             AND subscriptions.unsubscribed_at IS NULL
           GROUP BY subscriptions.mailing_list_id
          ) AS subscription_counts
       SET mailing_lists.active_subscriptions_count = subscription_counts.count
       WHERE mailing_lists.id = subscription_counts.mailing_list_id")
  end
end
