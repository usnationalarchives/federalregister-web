class UriUtils
  def self.swap_hostname(url, other_url)
    uri = URI.parse(url)
    other_uri = URI.parse(other_url)

    uri.hostname = other_uri.hostname
    uri.to_s
  end
end
