class Ofr::UserEmailResultSet
  def self.get_user_emails(user_ids)
    conn = Faraday.new
    conn.basic_auth(
      Rails.application.credentials.dig(:services, :ofr, :profile, :basic_username),
      Rails.application.credentials.dig(:services, :ofr, :profile, :basic_password)
    )
    response = conn.post "#{Settings.services.ofr.profile.internal_base_url}/api/profile/v1/emails", {ids: Array.wrap(user_ids)}
    JSON.parse(response.body)
  end
end
