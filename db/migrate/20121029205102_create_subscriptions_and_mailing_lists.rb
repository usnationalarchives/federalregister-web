class CreateSubscriptionsAndMailingLists < ActiveRecord::Migration
  def up
    create_table :mailing_lists do |t|
      t.text     :parameters
      t.string   :title
      t.integer  :active_subscriptions_count
      
      t.timestamps

      t.string   :type
    end
    
    # insert into mailing_lists select * from fr2_master_development.mailing_lists
    # update mailing_lists set type = 'MailingList::Article' where type = 'MailingList::Entry'

    create_table :subscriptions do |t|
      t.integer  :mailing_list_id
      t.string   :email
      t.string   :requesting_ip
      t.string   :token
      
      t.datetime :confirmed_at
      t.datetime :unsubscribed_at
      t.timestamps

      t.datetime :last_delivered_at
      t.integer  :delivery_count
      t.date     :last_issue_delivered
      t.string   :environment

      t.integer  :user_id
    end

    # insert into subscriptions ( id, mailing_list_id, email, requesting_ip, token, confirmed_at, unsubscribed_at, created_at, updated_at, last_delivered_at, delivery_count, last_issue_delivered, environment) select id, mailing_list_id, email, requesting_ip, token, confirmed_at, unsubscribed_at, created_at, updated_at, last_delivered_at, delivery_count, last_issue_delivered, environment from fr2_master_development.subscriptions
  end

  def down
    drop_table :subscriptions
    drop_table :mailing_lists
  end
end

