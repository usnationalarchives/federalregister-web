class DocumentDecorator < ApplicationDecorator
  delegate_all

  include DocumentDecorator::Shared

  include DocumentDecorator::Agencies
  include DocumentDecorator::Clippings
  include DocumentDecorator::Comments
  include DocumentDecorator::Corrections
  include DocumentDecorator::GovernmentPublishingOffice
  include DocumentDecorator::Officialness
  include DocumentDecorator::RegulationsDotGovInfo

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

  def end_page?
    end_page.present?
  end

  def page_range
    if start_page? && end_page?
      end_page != start_page ? "#{start_page}-#{end_page}" : start_page
    else
      nil
    end
  end

  def pages
    if start_page? && end_page?
      end_page - start_page + 1
    else
      'NA'
    end
  end

  def formatted_cfr_references
    cfr_references.uniq.map do |cfr|
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

  def full_text_available?
    full_text_xml_url.present?
  end

  def pdf_available?
    pdf_url.present?
  end

  def mods_available?
    mods_url.present?
  end

  def public_inspection_document?
    object.class == PublicInspectionDocument
  end

  def effective_date
    effective_on
  end

  def comments_close_date
    comments_close_on
  end

  def metadata_description
    return @document_metadata_description if @document_metadata_description

    description = "#{type.with_indefinite_article(true)} by " +
    content_tag(:span, agency_name_sentence, class: "agencies") +
    " on " +
    h.link_to(
      h.date_tag(publication_date, datetime: publication_date),
      h.document_issue_path(model)
    )

    @document_metadata_description = description.html_safe
  end

  def citation_vol
    return unless start_page?
    citation.split('FR').first().strip
  end
end
