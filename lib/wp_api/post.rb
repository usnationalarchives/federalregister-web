class WpApi::Post < WpApi::Content
  def path(section_identifier='office-of-the-federal-register-blog')
    url = link&.gsub('/blog/', "/reader-aids/#{section_identifier}/")

    return url unless Rails.env.development?

    # Links from WP are full urls to whatever instance we are
    # connected to. In development we want items to link to the url we
    # are on, not to staging or prod
    UriUtils.swap_hostname(url, Settings.services.fr.web.base_url)
  end

  def url(section_identifier='office-of-the-federal-register-blog')
    path(section_identifier)
  end

end
