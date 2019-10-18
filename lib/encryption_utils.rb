module EncryptionUtils
  def comment_salt
    self.salt = (self[:salt] || SecureRandom.hex(127))
  end

  def comment_iv
    self.iv = (self[:iv] || SecureRandom.hex(8))
  end

  def generate_cipher
    OpenSSL::Cipher.new('aes-256-cbc')
  end

  def encryption_key
    OpenSSL::PKCS5.pbkdf2_hmac(secret, comment_salt, 1000, 32, OpenSSL::Digest::SHA256.new)
  end

  def encryption_cipher
    cipher = generate_cipher
    cipher.encrypt
    cipher.key = encryption_key
    cipher.iv  = comment_iv
    cipher
  end

  def decryption_cipher
    cipher = generate_cipher
    cipher.decrypt
    cipher.key = encryption_key
    cipher.iv = comment_iv
    cipher
  end

  def encrypt(data)
    cipher = encryption_cipher
    cipher.update(data) + cipher.final
  end

  def decrypt(data)
    cipher = decryption_cipher
    cipher.update(data) + cipher.final
  end
end
