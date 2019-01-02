namespace :email do
  namespace :notification do
    task :deliver_to_my_fr_subscribers, [:notification] => :environment do |t, args|
      notification = EmailNotification.find( args[:notification] )

      raise "Notification '#{notification}' not found!" unless notification

      email_query = "SELECT users.email
                     FROM subscriptions, users
                     WHERE subscriptions.user_id IS NOT NULL
                       && subscriptions.user_id = users.id
                       && subscriptions.environment = '#{Rails.env}'
                     GROUP BY users.email"
      emails = ActiveRecord::Base.connection.execute( email_query ).to_a.flatten
      emails.each_slice(1000) do |emails|
        puts "Delivering notification to: #{emails.inspect}"

        notification.deliver_now(emails)
      end
    end
  end
end
