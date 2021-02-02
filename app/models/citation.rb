class Citation
  attr_reader :document_numbers, :public_inspection, :volume, :page

  include RouteBuilder::ExternalUrls

  PATTERN = /(\d+)\s+(?:CFR|C\.F\.R\.)\s+(?:[Pp]arts?|[Ss]ections?|[Ss]ec\.|&#xA7;|&#xA7;\s*&#xA7;)?\s*(\d+)(?:\.(\d+))?/

  CITATION_TYPES = {
    'USC' => /(\d+)\s+U\.?S\.?C\.?\s+(\d+)/,
    'CFR' => /(\d+)\s+CFR\s+(\d+)(?:\.(\d+))?/,
    'FR'  => /(\d+)\s+FR\s+(\d+)/,
    'FR-DocNum' => /(?:FR Doc(?:\.|ument)? )([A-Z0-9]+-[0-9]+)(?:[,;\. ])/i,
    'PL'  => /Pub(?:lic|\.)\s+L(?:aw|\.)\.\s+(\d+)-(\d+)/,
    'EO'  => /(?:EO|E\.O\.|Executive Order) (\d+)/
  }

  def initialize(options)
    options = options || {}
    @document_numbers = options["document_numbers"] || []
    @public_inspection = options["public_inspection"].try(:[], "count")
    @volume            = options["volume"]
    @page              = options["page"]
  end

  def matching_fr_entries
    return [] unless document_numbers.present?

    begin
      Document.find_all(document_numbers).map do |d|
        DocumentDecorator.decorate(d)
      end
    rescue FederalRegister::Client::RecordNotFound
      []
    end
  end

  def url
    case citation_type
    when 'USC'
      govinfo_usc_pdf_url(part_1, part_2)
    when 'CFR'
      govinfo_cfr_pdf_url(part_1, part_2, part_3)
    when 'FR'
      "/citation/#{part_1}/#{part_2}" if part_1.to_i >= 59
    when 'FR-DocNum'
      "/d/#{part_1}"
    when 'PL'
      govinfo_public_law_pdf_url(part_1, part_2) if part_1.to_i >= 104
    end
  end

  def name
    case citation_type
    when 'USC'
      "#{part_1} U.S.C. #{part_2}"
    when 'CFR'
      "#{part_1} CFR #{part_2}" + (part_3.blank? ? '' : ".#{part_3}")
    when 'FR'
      "#{part_1} FR #{part_2}"
    when 'FR-DocNum'
      "FR Doc. #{part_1}"
    when 'PL'
      "Public Law #{part_1}-#{part_2}"
    when 'EO'
      "Executive Order #{part_1}"
    end
  end

  def citation_type
    @citation_type ||= matching_fr_entries.each do |entry|
      return CITATION_TYPES.
        detect{|type, regexp| entry.citation.match(regexp)}.
        first
    end
  end

  def part_1
    matching_fr_entries.first.citation.split(" ").first
  end

  def part_2
    matching_fr_entries.first.citation.split(" ").last
  end
end
