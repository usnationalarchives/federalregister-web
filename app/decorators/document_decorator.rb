class DocumentDecorator < ApplicationDecorator
  delegate_all

  include DocumentDecorator::Shared
  include DocumentDecorator::Comments
  include DocumentDecorator::Corrections

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

  def start_page?
    start_page.present? && start_page != 0
  end

  # Dec 17th, 2013
  def shorter_ordinal_signing_date
    signing_date.to_s(:shorter_ordinal)
  end

  def page_range
    page = start_page
    page = "#{page}-#{end_page}" if end_page != start_page
  end

  def length
    if end_page && start_page
      end_page - start_page + 1
    else
      nil
    end
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

  def human_length
    if end_page && start_page
      end_page - start_page + 1
    else
      nil
    end
  end

  def effective_date
    effective_on
  end

  def comments_close_date
    comments_close_on
  end

  def pages
    # RW: placeholder
    end_page - start_page == 0 ? 1 : end_page - start_page + 1
  end

  def agency_dt_dd
    # RW: placeholder
  end

  def docket_dt_dd
    # RW: placeholder
  end
end
