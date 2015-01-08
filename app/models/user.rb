class User < ActiveRecord::Base
  model_stamper

  has_many :authentications
  has_many :clippings
  has_many :comments
  has_many :subscriptions

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
#         :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name

  after_create :migrate_subscriptions_to_new_user_account

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    auth = Authentication.find_by_provider_and_uid(access_token['provider'], access_token['uid'])
    data = access_token['extra']['raw_info']

    user = apply_auth_sign_in_or_create_user_with_stub_password(auth, access_token, data)
    user
  end

  def self.find_for_twitter_oauth(access_token, signed_in_resource=nil)
    auth = Authentication.find_by_provider_and_uid(access_token['provider'], access_token['uid'])
    data = access_token['extra']['raw_info']

    user = apply_auth_sign_in_or_create_user_with_stub_password(auth, access_token, data)
    user
  end

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

  def apply_auth_sign_in_or_create_user_with_stub_password(auth, access_token, data)
    if auth
      user = auth.user
    elsif signed_in_resource
      user = signed_in_resource
      user.apply_omniauth(access_token)
      user.update_user_from_omniauth(access_token['provider'], data)
    else
      if data[:email] && user = User.find_by_email(data[:email]) #twitter doesn't provide email in the data it returns
        user.apply_omniauth(access_token)
      else # Create a user with a stub password.
        user = User.new(:email => data[:email], :encrypted_password => Devise.friendly_token[0,20])
        user.apply_omniauth(access_token)
        user.save!
        user.update_user_from_omniauth(access_token['provider'], data)
      end
    end

    user
  end

  def apply_omniauth(access_token)
    authentications.build(:provider => access_token['provider'], :uid => access_token['uid'])
  end

  def update_user_from_omniauth(provider, raw_info)
    case provider
    when "facebook"
      update_first_and_last_name(raw_info[:first_name], raw_info[:last_name]) if !self.first_name && !self.last_name
    when "twitter"
      name = raw_info[:name].split(' ') if raw_info[:name]
      update_first_and_last_name(name[0...-1].join(' '), name[-1]) if name && !self.first_name && !self.last_name
    end
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
