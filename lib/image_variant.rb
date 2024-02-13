# NOTE: This should be extracted to the federal_register gem
class ImageVariant < FederalRegister::Base
  add_attribute :content_type,
    :height,
    :sha,
    :size,
    :style,
    :url,
    :width

  def self.find(image_identifier, options = {})
    query = {}

    response = get("/images/#{URI.encode_www_form_component(image_identifier)}", query: query).parsed_response

    response.map do |style, attributes|
      new(attributes.merge("style" => style))
    end
  end
end
