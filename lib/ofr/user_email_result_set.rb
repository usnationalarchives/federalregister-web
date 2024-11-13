class Ofr::UserEmailResultSet
  def self.get_user_emails(user_ids)
    conn = Faraday.new do |conn|
      conn.request :json            # Encode request bodies as JSON
      conn.request :authorization,
        :basic,
        Rails.application.credentials.dig(:services, :ofr, :profile, :basic_username),
        Rails.application.credentials.dig(:services, :ofr, :profile, :basic_password)
    end
    response = conn.post "#{Settings.services.ofr.profile.internal_base_url}/api/profile/v1/emails", {ids: user_ids}
    JSON.parse(response.body)
  end
end
