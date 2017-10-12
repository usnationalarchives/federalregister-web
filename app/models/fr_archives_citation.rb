class FrArchivesCitation
  include HTTParty
  base_uri Settings.federal_register_archives.api_url

  def initialize(volume, page)
    @options = { query: { volume: volume, page: page } }
  end

  def pdf_url
    if response.code != 404
      response.fetch("pdf_url")
    else
      nil
    end
  end

  private

  def page_offset
    response.fetch("page_offset")
  end

  def response
    @response ||= self.class.get('/api/archives/v1/citation.json', @options)
  end

end

