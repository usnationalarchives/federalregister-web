class JwtUtils
  def self.encode(hsh)
    encoding_key_present!

    JWT.encode(hsh, jwt_secret_key, 'HS256')
  end

  def self.decode(token)
    begin
      JWT.decode(token, jwt_secret_key, true, {algorithm: 'HS256'}).first
    rescue
      nil
    end
  end

  private

  def self.encoding_key_present!
    raise "Need to set jwt_secret" unless jwt_secret_key.present?
  end

  def self.jwt_secret_key
    Rails.application.credentials.dig(:services, :ofr, :profile, :jwt_secret).to_s
  end
end
