class WpApi::Page < WpApi::Content
  include Rails.application.routes.url_helpers
  def path(section_identifier)
    reader_aid_path(section_identifier, slug)
  end

  def slug
    link.split("/").last
  end
end
