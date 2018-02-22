module OauthTestHelpers

  def stubbed_auth_hash
    OmniAuth::AuthHash.new({
      credentials: OmniAuth::AuthHash.new({
        token: "Atnjv-WkRGSuhlKxcGFGbw"
      }),
      provider: 'ofr',
      uid:      '123545',
      extra:    OmniAuth::AuthHash.new({
        raw_info: OmniAuth::AuthHash.new({
          email:           "john_doe@example.com",
          email_confirmed: true
        })
      })
    })
  end

end
