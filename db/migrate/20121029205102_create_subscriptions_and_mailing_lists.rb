class CreateSubscriptionsAndMailingLists < ActiveRecord::Migration
  def up
    create_table :mailing_lists do |t|
      t.text     :parameters
      t.string   :title
      t.integer  :active_subscriptions_count, :default => 0, :null => false

      t.timestamps

      t.string   :type
    end

    execute "insert into mailing_lists select * from fr2_production.mailing_lists"
    execute "update mailing_lists set type = 'MailingList::Article' where type = 'MailingList::Entry'"

    create_table :subscriptions do |t|
      t.integer  :mailing_list_id
      t.string   :email
      t.string   :requesting_ip
      t.string   :token

      t.datetime :confirmed_at
      t.datetime :unsubscribed_at
      t.timestamps

      t.datetime :last_delivered_at
      t.integer  :delivery_count, :default => 0, :null => false
      t.date     :last_issue_delivered
      t.string   :environment

      t.integer  :user_id
    end

    execute <<-SQL
      INSERT INTO subscriptions
      (
        id,
        mailing_list_id,
        email,
        requesting_ip,
        token,
        confirmed_at,
        unsubscribed_at,
        created_at, updated_at, last_delivered_at, delivery_count, last_issue_delivered, environment
      )
      SELECT id, mailing_list_id, email, requesting_ip, token, confirmed_at, unsubscribed_at, created_at, updated_at, last_delivered_at, delivery_count, last_issue_delivered, environment
      FROM fr2_production.subscriptions
    SQL
  end

  def down
    drop_table :subscriptions
    drop_table :mailing_lists
  end
end

