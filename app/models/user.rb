class User < ActiveRecord::Base
  model_stamper

  has_many :authentications
  has_many :clippings
  has_many :comments
  has_many :subscriptions
  has_many :folders, :foreign_key => :creator_id

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name

  after_create :migrate_subscriptions_to_new_user_account

  def migrate_subscriptions_to_new_user_account
    associate_subscriptions
    clean_up_subscriptions
  end

  private

  def associate_subscriptions
    Subscription.confirmed.where(:email => email).update_all(:user_id => id)
    Subscription.unconfirmed.where(:email => email).where("created_at > ?", 1.week.ago).update_all(:user_id => id)
  end

  def clean_up_subscriptions
    Subscription.unconfirmed.where(:email => email).where("created_at < ?", 1.week.ago).delete_all
  end

  protected

  def password_required?
    (authentications.empty? || password.present?) && super
  end

  def email_required?
    authentications.empty? && super
  end

  def update_first_and_last_name(first_name, last_name)
    self.update_attributes(:first_name => first_name, :last_name => last_name)
  end

  def email_required?
    authentications.empty? && super
  end

  def confirmation_period_valid?
    true #we don't force confirmation of email address (just limit what is seen on a page)
  end
end
