class Ecfr::UserEmailResultSet

  def self.get_user_emails(user_ids)
    conn = Faraday.new(:url => Settings.services.fr_profile_url)
    conn.basic_auth(
      SECRETS["fr_profile"]["basic_username"],
      SECRETS["fr_profile"]["basic_username"],
    )
    response = conn.post '/api/profile/v1/emails', {ids: Array.wrap(user_ids)}
    JSON.parse(response.body)
  end

end
