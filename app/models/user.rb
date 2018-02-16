class User

  attr_reader :id, :email, :email_confirmed, :token

  def self.find(user_id)
    return unless user_id

    email = Ecfr::UserEmailResultSet.get_user_emails(user_id).values.first

    if email
      new("sub" => user_id, "email" => email)
    end
  end

  def initialize(sso_attributes)
    self.sso_attributes=(sso_attributes)
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
