class Ofr::UserEmailResultSet
  def self.get_user_emails(user_ids)
    conn = Faraday.new
    conn.basic_auth(
      Rails.application.secrets[:fr_profile][:basic_username],
      Rails.application.secrets[:fr_profile][:basic_password],
    )
    response = conn.post "#{Settings.services.fr_profile_internal_url}/api/profile/v1/emails", {ids: Array.wrap(user_ids)}
    JSON.parse(response.body)
  end
end
