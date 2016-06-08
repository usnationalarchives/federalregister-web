class Citation
  attr_reader :document_numbers, :public_inspection

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
  end

  def matching_fr_entries
    Document.find_all(document_numbers).map do |d|
      DocumentDecorator.decorate(d)
    end
  end

  def url
    case citation_type
    when 'USC'
      "https://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=browse_usc&docid=Cite:+#{part_1}USC#{part_2}"
    when 'CFR'
      "https://frwebgate.access.gpo.gov/cgi-bin/get-cfr.cgi?YEAR=current&TITLE=#{part_1}&PART=#{part_2}&SECTION=#{part_3}&SUBPART=&TYPE=TEXT"
    when 'FR'
      "/citation/#{part_1}/#{part_2}" if part_1.to_i >= 59
    when 'FR-DocNum'
      "/a/#{part_1}"
    when 'PL'
      "https://frwebgate.access.gpo.gov/cgi-bin/getdoc.cgi?dbname=#{part_1}_cong_public_laws&docid=f:publ#{sprintf("%03d",part_2.to_i)}.#{part_1}" if part_1.to_i >= 104
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
