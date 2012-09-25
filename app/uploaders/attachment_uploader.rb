class AttachmentUploader < CarrierWave::Uploader::Base
  require 'openssl'

  # storage :file
  storage :fog
  store_dir 'comment_attachments'

  process :persist_md5
  process :encrypt_file

  # this shouldn't be necesary, but carrierwave really wants to use the hostname...
  def url(*args)
    uri = URI.parse( super )
    bucket = uri.host.sub(/\.s3\.amazonaws\.com$/,'')
    "https://s3.amazonaws.com/#{bucket}#{uri.path}?#{uri.query}"
  end

  private

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
      cipher.iv  = model.iv
      
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
        Cocaine::CommandLine.new("srm", original_file_path).run
      end
    end
  end
end
