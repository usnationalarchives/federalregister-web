module Hyperlinker::Citation
  module UrlHelpers
    def usc_url(title, section)
      "https://api.fdsys.gov/link?collection=uscode&title=#{title}&year=mostrecent&section=#{section}&type=usc&link-type=html"
    end

    def public_law_url(congress, law)
      "https://api.fdsys.gov/link?collection=plaw&congress=#{congress}&lawtype=public&lawnum=#{law.to_i}&link-type=html"
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
      return if volume.blank?

      "https://www.gpo.gov/fdsys/pkg/CFR-#{year}-title#{title}-vol#{volume}/xml/CFR-#{year}-title#{title}-vol#{volume}-#{section.present? ? "sec#{part}-#{section}" : "part#{part}"}.xml"
    end

    def ecfr_url(title,part)
      "http://www.ecfr.gov/cgi-bin/searchECFR?idno=#{title}&q1=#{part}&rgn1=PARTNBR&op2=and&q2=&rgn2=Part"
    end
  end

  extend Hyperlinker::Citation::UrlHelpers
  extend ActionView::Helpers::TagHelper
  extend RouteBuilder::Fr2Urls

  def self.perform(text, options={})
    text = add_eo_links(text)
    text = add_usc_links(text)
    text = add_cfr_links(text, options[:date])
    text = add_federal_register_links(text)
    text = add_federal_register_doc_number_links(text)
    text = add_regulatory_plan_links(text) if Settings.regulatory_plan
    text = add_public_law_links(text)
    text = add_patent_links(text)
    text = add_omb_control_number_links(text)
  end

  def self.add_eo_links(text)
    text.gsub(/(?:\bE\.\s*O\.|\bE\s*O\b|\bExecutive Order\b)(?:\s+No\.?)?\s+([0-9,]+)/i) do |str|
      eo_number = $1.gsub(/,/,'').to_i
      if eo_number >= 12890
        content_tag :a, str, :href => executive_order_path(eo_number), :class => "eo"
      else
        str
      end
    end
  end

  def self.add_usc_links(text)
    text.gsub(/(\d+)\s+U\.?S\.?C\.?\s+(\d+)/) do |str|
      title = $1
      part = $2
      content_tag :a, str,
          :href => usc_url(title, part),
          :class => "usc external",
          :target => "_blank"
    end
  end

  def self.add_cfr_links(text, date=nil)
    date ||= Time.current.to_date
    text.gsub(/(\d+)\s+(?:CFR|C\.F\.R\.)\s+(?:[Pp]arts?|[Ss]ections?|[Ss]ec\.|&#xA7;|&#xA7;\s*&#xA7;)?\s*(\d+)(?:\.(\d+))?/) do |str|
      title = $1
      part = $2
      section = $3

      content_tag(:a, str.html_safe, :href => select_cfr_citation_path(date,title,part,section), :class => "cfr external")
    end
  end

  def self.add_federal_register_links(text)
    text.gsub(/(\d+)\s+FR\s+(\d+)/) do |str|
      volume = $1
      page = $2
      if volume.to_i >= 60 # we have 59, but not the page numbers so this feature doesn't help
        content_tag(:a, str, :href => citation_path(volume,page))
      else
        str
      end
    end
  end

  def self.add_federal_register_doc_number_links(text)
    text.gsub(/(FR Doc\.? )([A-Z0-9]+-[0-9]+)([,;\. ])/) do |str|
      pre = $1
      doc_number = $2
      post = $3

      "#{pre}#{content_tag(:a, doc_number, :href => "/a/#{doc_number}")}#{post}"
    end
  end

  def self.add_regulatory_plan_links(text)
    text.gsub(/\b(\d{4}\s*-\s*[A-Z]{2}\d{2})\b/) do |str|
      content_tag :a, str, :href => short_regulatory_plan_path(:regulation_id_number => $1)
    end
  end

  def self.add_public_law_links(text)
    text.gsub(/(?:Public Law|Pub\. Law|Pub\. L.|P\.L\.)\s+(\d+)-(\d+)/) do |str|
      congress = $1
      law = $2
      if congress.to_i >= 104
        content_tag :a, str, :href => public_law_url(congress,law), :class => "publ external", :target => "_blank"
      else
        $1
      end
    end
  end

  def self.add_patent_links(text)
    text = text.gsub(/Patent Number ([0-9,]+)/) do |str|
      number = $1
      content_tag :a, str, :href => patent_url(number), :class => "patent external", :target => "_blank"
    end
  end

  def self.add_omb_control_number_links(text)
    if text =~ /OMB/
      text = text.gsub(/(\s)(\d{4}\s*-\s*\d{4})([ \.;,]|$)/) do |str|
        pre = $1
        number = $2
        post = $3
        "#{pre}#{content_tag(:a, number, :href => omb_control_number_url(number), :class => "omb_number external", :target => "_blank")}#{post}"
      end
    end

    text
  end
end
