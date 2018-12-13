module Hyperlinker::Citation
  module UrlHelpers
    def usc_url(title, section)
      "https://www.govinfo.gov/link/uscode/#{title}/#{section}?type=usc&year=mostrecent&link-type=html"
    end

    def public_law_url(congress, law)
      "https://www.govinfo.gov/link/plaw/#{congress}/public/#{law.to_i}?link-type=html"
    end

    def patent_url(number_possibly_with_commas)
      number = number_possibly_with_commas.gsub(/,/,'')
      "http://patft.uspto.gov/netacgi/nph-Parser?Sect2=PTO1&Sect2=HITOFF&p=1&u=/netahtml/PTO/search-bool.html&r=1&f=G&l=50&d=PALL&RefSrch=yes&Query=PN/#{number}"
    end

    def omb_control_number_url(number)
      "http://www.reginfo.gov/public/do/PRAOMBHistory?ombControlNumber=#{number}"
    end

    def cfr_url(year, title, volume, part, section='')
      return if year.blank?
      return if title.blank?
      return if part.blank?

      "https://www.govinfo.gov/link/cfr/#{title}/#{part}?sectionnum=#{section}&year=#{year}&link-type=xml"
    end

    def ecfr_url(title,part)
      "http://www.ecfr.gov/cgi-bin/searchECFR?idno=#{title}&q1=#{part}&rgn1=PARTNBR&op2=and&q2=&rgn2=Part"
    end
  end

  extend Hyperlinker::Citation::UrlHelpers
  extend ActionView::Helpers::TagHelper

  class << self
    include Rails.application.routes.url_helpers
    include RouteBuilder::Citations
  end

  def self.perform(text, options={})
    text = add_eo_links(text)
    text = add_usc_links(text)
    text = add_cfr_links(text, options[:date])
    text = add_federal_register_links(text)
    text = add_federal_register_doc_number_links(text)
    text = add_regulatory_plan_links(text) if Settings.regulatory_plan
    text = add_public_law_links(text)
    text = add_patent_links(text)
  end

  def self.add_eo_links(text)
    Hyperlinker.replace_text(text, /(?:\bE\.\s*O\.|\bE\s*O\b|\bExecutive Order\b)(?:\s+No\.?)?\s+([0-9,]+)/i) do |match|
      eo_number = match[1].gsub(/,/,'').to_i
      if eo_number >= 12890
        content_tag :a, match.to_s, :href => executive_order_path(eo_number), :class => "eo"
      else
        match.to_s
      end
    end
  end

  def self.add_usc_links(text)
    Hyperlinker.replace_text(text, /(\d+)\s+U\.?S\.?C\.?\s+(\d+)/) do |match|
      title, part = match.captures
      content_tag :a, match.to_s,
          :href => usc_url(title, part),
          :class => "usc external",
          :target => "_blank"
    end
  end

  def self.add_cfr_links(text, date=nil)
    date ||= Time.current.to_date
    Hyperlinker.replace_text(text, /(\d+)\s+(?:CFR|C\.F\.R\.)\s+(?:[Pp]arts?|[Ss]ections?|[Ss]ec\.|&#xA7;|&#xA7;\s*&#xA7;)?\s*(\d+)(?:\.(\d+))?/) do |match|
      title, part, section = match.captures

      content_tag(:a, match.to_s.html_safe, :href => select_cfr_citation_path(date,title,part,section), :class => "cfr external")
    end
  end

  def self.add_federal_register_links(text)
    Hyperlinker.replace_text(text, /(\d+)\s+FR\s+(\d+)/) do |match|
      volume, page = match.captures
      content_tag(:a, match.to_s, :href => citation_path(volume,page))
    end
  end

  def self.add_federal_register_doc_number_links(text)
    Hyperlinker.replace_text(text, /(FR Doc\.? )([A-Z0-9]+-[0-9]+)([,;\. ])/) do |match|
      pre, doc_number, post = match.captures

      "#{pre}#{content_tag(:a, doc_number, :href => "/a/#{doc_number}")}#{post}"
    end
  end

  def self.add_regulatory_plan_links(text)
    Hyperlinker.replace_text(text, /\b(\d{4}\s*-\s*[A-Z]{2}\d{2})\b/) do |match|
      content_tag :a, match.to_s, :href => short_regulatory_plan_path(:regulation_id_number => match[1])
    end
  end

  def self.add_public_law_links(text)
    Hyperlinker.replace_text(text, /(?:Public Law|Pub\. Law|Pub\. L.|P\.L\.)\s+(\d+)-(\d+)/) do |match|
      congress, law = match.captures

      if congress.to_i >= 104
        content_tag :a, match.to_s, :href => public_law_url(congress,law), :class => "publ external", :target => "_blank"
      else
        match.to_s
      end
    end
  end

  def self.add_patent_links(text)
    Hyperlinker.replace_text(text, /Patent Number ([0-9,]+)/) do |match|
      number = match[1]
      content_tag :a, match.to_s, :href => patent_url(number), :class => "patent external", :target => "_blank"
    end
  end
end
