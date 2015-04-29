class DocumentDecorator < ApplicationDecorator
  delegate_all

  include DocumentDecorator::Shared

  include DocumentDecorator::Agencies
  include DocumentDecorator::Comments
  include DocumentDecorator::Corrections
  include DocumentDecorator::Officialness

  def slug
    html_url.split('/').last
  end

  def presidential_document?
    type == "Presidential Document"
  end

  def http_abstract_html_url
    # RW: Fix this when upgrading varnish
    abstract_html_url.
      gsub("https", "http")
  end

  def http_body_html_url
    body_html_url.
      gsub("https", "http")
  end

  # Dec 17th, 2013
  def shorter_ordinal_signing_date
    signing_date.to_s(:shorter_ordinal)
  end

  # Page Count/Range methods
  def start_page?
    start_page.present? && start_page != 0
  end

  def page_range
    end_page != start_page ? "#{start_page}-#{end_page}" : start_page
  end

  def pages
    end_page - start_page + 1
  end

  def formatted_cfr_references
    cfr_references.map do |cfr|
      str = ["#{cfr["title"]} CFR"]

      if cfr["chapter"].present?
        str << "chapter #{h.number_to_roman(cfr["chapter"])}"
      else
        str << cfr["part"]
      end
      str = str.join(' ')

      if cfr["citation_url"].present?
        h.link_to str, cfr["citation_url"]
      else
        str
      end
    end
  end

  def has_full_text?
    full_text_xml_url.present?
  end

  def effective_date
    effective_on
  end

  def comments_close_date
    comments_close_on
  end
end
