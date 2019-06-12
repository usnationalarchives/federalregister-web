class AttachmentUploader < CarrierWave::Uploader::Base
  require 'openssl'

  # storage :file
  storage :fog
  store_dir 'comment_attachments'

  process :generate_token
  process :persist_md5
  process :encrypt_file

  def filename
     "#{model.token}.#{file.extension}" if original_filename.present?
  end

  private

  def generate_token
    model.token = SecureRandom.hex(32)
  end

  def persist_md5
    model.attachment_md5 = Digest::MD5.hexdigest(model.attachment.read)
  end

  def encrypt_file
    begin
      original_file_path = "#{current_path}.orig"
      FileUtils.move(current_path, original_file_path)

      cipher = model.generate_cipher
      cipher.encrypt
      cipher.key = model.encryption_key
      cipher.iv  = model.comment_iv

      buf = ""
      File.open(current_path, "wb") do |outf|
        File.open(original_file_path, "rb") do |inf|
          while inf.read(4096, buf)
            outf << cipher.update(buf)
          end
          outf << cipher.final
        end
      end
    ensure
      if File.exists?(original_file_path)
        pid = Process.fork
        if pid.nil?
          # In child
          exec("srm #{original_file_path}")
        else
          # In parent
          Process.detach(pid)
        end
      end
    end
  end
end
