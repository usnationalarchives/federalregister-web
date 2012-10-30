class User < ActiveRecord::Base
  model_stamper

  has_many :authentications
  has_many :clippings
  has_many :comments

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
#         :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    auth = Authentication.find_by_provider_and_uid(access_token['provider'], access_token['uid'])
    data = access_token['extra']['raw_info']

    if auth
      user = auth.user
    elsif signed_in_resource
      user = signed_in_resource
      user.apply_omniauth(access_token)
      user.update_user_from_omniauth(access_token['provider'], data)
    else
      if user = User.find_by_email(data[:email])
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

  def self.find_for_twitter_oauth(access_token, signed_in_resource=nil)
    auth = Authentication.find_by_provider_and_uid(access_token['provider'], access_token['uid'])
    data = access_token['extra']['raw_info']

    if auth
      user = auth.user
    elsif signed_in_resource
      user = signed_in_resource
      user.apply_omniauth(access_token)
      user.update_user_from_omniauth(access_token['provider'], data)
    else
      user = User.new(:email => data[:email], :encrypted_password => Devise.friendly_token[0,20])
      user.apply_omniauth(access_token)
      user.save!
      user.update_user_from_omniauth(access_token['provider'], data)
    end
    user
  end

  def apply_omniauth(access_token)
    authentications.build(:provider => access_token['provider'], :uid => access_token['uid'])
  end

  def update_user_from_omniauth(provider, raw_info)
    case provider
    when "facebook"
      if !self.first_name && !self.last_name
        self.update_attributes(:first_name => raw_info[:first_name], :last_name => raw_info[:last_name])
      end
    when "twitter"
      name = data[:name].split(' ') if data[:name]
      if name && !self.first_name && !self.last_name
        self.update_attributes(:first_name => name[0...-1].join(' '), :last_name => name[-1])
      end
    end
  end

  protected

  def password_required?  
    (authentications.empty? || password.present?) && super  
  end

  def email_required?
    authentications.empty? && super
  end

end
