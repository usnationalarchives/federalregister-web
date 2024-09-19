class FrArchivesCitation
  include HTTParty
  base_uri Settings.services.fr.archives.internal_base_url

  def initialize(volume, page)
    @volume = volume
    @page   = page
  end

  def download_link_available?
    issue_slice_available? || gpo_url
  end

  def issue_slice_page_range
    if issue_slice_available?
      if issue_slice_start_page == issue_slice_end_page
        "#{issue_slice_start_page}"
      else
        "#{issue_slice_start_page}-#{issue_slice_end_page}"
      end

    end
  end

  def issue_slice_url
    if issue_slice_available?
      "#{response_url}#page=#{specific_page}"
    end
  end

  def gpo_url
    response["gpo_url"]
  end

  def original_file_size
    response["original_file_size"]
  end

  def optimized_file_size
    response["slice_file_size"]
  end

  def before_archives?
    (response.code == 404) && is_before_archives
  end

  def after_archives?
    (response.code == 404) && is_after_archives
  end

  def publication_date
    begin
      Date.parse response["publication_date"]
    rescue
      nil
    end
  end

  def omni_search_citation
    "#{volume} FR #{page}"
  end

  private

  attr_reader :volume, :page

  def is_before_archives
    response["before_archives"] == true
  end

  def is_after_archives
    response["after_archives"]
  end

  def issue_slice_available?
    response['pdf_url']
  end

  def response_url
    response.fetch("pdf_url")
  end

  def specific_page
    if page_offset == 0
      1
    else
      page_offset + 1
    end
  end

  def issue_slice_start_page
    response.fetch("slice_start_page")
  end

  def issue_slice_end_page
    response.fetch("slice_end_page")
  end

  def page_offset
    response.fetch("page_offset")
  end

  def response
    @response ||= self.class.get('/api/archives/v1/citation.json', options)
  end

  def options
    { query: { volume: volume, page: page } }
  end

end
