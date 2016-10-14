class WpApi::Page < WpApi::Content
  include Rails.application.routes.url_helpers
  def path(section_identifier)
    reader_aid_path(section_identifier, slug)
  end

  def url(section_identifier)
    reader_aid_url(section_identifier, slug)
  end
end
