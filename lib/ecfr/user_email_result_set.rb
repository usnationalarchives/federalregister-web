class Ecfr::UserEmailResultSet

  def self.get_user_emails(user_ids)
    conn = Faraday.new
    conn.basic_auth(
      SECRETS["fr_profile"]["basic_username"],
      SECRETS["fr_profile"]["basic_password"],
    )
    response = conn.post "#{Settings.services.fr_profile_url}/api/profile/v1/emails", {ids: Array.wrap(user_ids)}
    JSON.parse(response.body)
  end

end
