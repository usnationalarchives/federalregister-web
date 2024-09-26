class FrArchivesClient

  def self.client
    if Settings.log_http_requests
      Faraday.new(url: Settings.services.fr.archives.internal_base_url) do |faraday|
        faraday.request :url_encoded
        faraday.use Ecfr::Client::FaradayInstrumentation
        faraday.adapter  Faraday.default_adapter
      end
    else
      Faraday.new(url: Settings.services.fr.archives.internal_base_url)
    end
  end

  def self.citations(volume, page)
    response = client.get('/api/archives/v1/citations.json', volume: volume, page: page)
    citations_response = JSON.parse(response.body)
    citations_response.map do |citation_response|
      FrArchivesCitation.new(volume, page, citation_response)
    end
  end

end
