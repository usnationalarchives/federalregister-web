# A copy of this class exists in -api-core also (for image import). Besure to update both!
module GpoImages
  module ImageIdentifierNormalizer
    def normalize_image_identifier(filename)
      if Settings.feature_flags.use_carrierwave_images_in_api
        remove_extensions(filename).upcase
      else
        remove_extensions(filename).downcase
      end
    end

    def remove_extensions(filename)
      filename.gsub(/\.?eps/i,"")
    end
  end
end
