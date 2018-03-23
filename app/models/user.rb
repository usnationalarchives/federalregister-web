class User
  class StaleOauthToken < StandardError; end

  attr_reader :id, :email, :email_confirmed, :token

  def self.find(user_id)
    return unless user_id

    email = Ecfr::UserEmailResultSet.get_user_emails(user_id).values.first

    if email
      new("sub" => user_id, "email" => email)
    end
  end

  def self.current=(user)
    RequestStore.store[:current_user] = user
  end

  def self.current
    RequestStore.store[:current_user]
  end


  def initialize(sso_attributes)
    self.sso_attributes=(sso_attributes)
  end

  def refresh
    conn = Faraday.new
    response = conn.get "#{Settings.services.fr_profile_url}/oauth/userinfo" do |req|
      req.headers["Authorization"]= "Bearer #{token}"
    end

    if response.status == 200
      self.sso_attributes = JSON.parse(response.body)
      response.body
    else
      raise StaleOauthToken
    end
  end

  def clippings
    Clipping.where(user_id: id)
  end

  def comments
    Comment.where(user_id: id)
  end

  def confirmed?
    email_confirmed.present?
  end

  def folders
    Folder.where(creator_id: id)
  end

  def subscriptions
    Subscription.where(user_id: id)
  end


  private

  def sso_attributes=(sso_attributes)
    @id              = sso_attributes["sub"].to_i
    @email           = sso_attributes["email"]
    @email_confirmed = sso_attributes["email_confirmed"]
    @token           ||= sso_attributes["token"]
  end
end
