class Hyperlinker
  require 'hyperlinker/citation'
  def self.perform(string, options={})
    new(options).perform(string)
  end

  AUTO_LINK_CRE = [/<[^>]+$/, /^[^>]*>/, /<a\b.*?>/i, /<\/a>/i]

  def self.replace_text(text, regexp)
    text.gsub(regexp) do
      match_data = Regexp.last_match
      left, right = match_data.pre_match, match_data.post_match

      previously_linked = ((left =~ AUTO_LINK_CRE[0] and right =~ AUTO_LINK_CRE[1]) or
        (left.rindex(AUTO_LINK_CRE[2]) and $' !~ AUTO_LINK_CRE[3]))

      if previously_linked
        match_data[0]
      else
        yield(match_data)
      end
    end
  end

  attr_reader :options
  def initialize(options={})
    @options = options
  end

  def perform(string)
    processors.each do |processor|
      string = processor.perform(string, options)
    end

    string
  end

  def processors
    [
      Hyperlinker::Url,
      Hyperlinker::Email,
      Hyperlinker::Citation,
    ]
  end
end
