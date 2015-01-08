module EncryptionUtils
  def salt
    self.salt = (self[:salt] || SecureRandom.hex(127))
  end

  def iv
    self.iv = (self[:iv] || SecureRandom.hex(127))
  end

  def generate_cipher
    OpenSSL::Cipher.new('aes-256-cbc')
  end

  def encryption_key
    PBKDF2.new(:password => secret, :salt=> salt, :iterations=>1000, :key_length => 256).bin_string
  end

  def encryption_cipher
    cipher = generate_cipher
    cipher.encrypt
    cipher.key = encryption_key
    cipher.iv  = iv
    cipher
  end

  def decryption_cipher
    cipher = generate_cipher
    cipher.decrypt
    cipher.key = encryption_key
    cipher.iv = iv
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
