# A copy of this class exists in -api-core also (for image import). Besure to update both!
module GpoImages
  module ImageIdentifierNormalizer
    def normalize_image_identifier(filename)
      remove_extensions(filename).upcase.strip
    end

    def remove_extensions(filename)
      filename.gsub(/\.?eps/i,"")
    end
  end
end
