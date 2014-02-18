module FrBoxHelper

  def fr_box(title, type, options, &block)
    box_options = options.fetch(:box_html) { Hash.new }
    header_options = options.fetch(:header) { Hash.new }

    content_tag(:div, class: "fr-box #{css_class_by_type(type)} #{box_options[:class]}", role: box_options[:role]) do
      fr_box_header(title, type, default_header_options.merge!(header_options)) +
        content_tag(:div, capture(&block), class: "content-block") +
        fr_box_footer(title, type)
    end
  end

  def fr_box_small(title, type, &block)
    content_tag(:div, class: "fr-box fr-box-small #{css_class_by_type(type)}") do
      fr_box_header(title, type, default_header_options) +
        content_tag(:div, capture(&block), class: "content-block") +
        fr_box_footer(title, type)
    end
  end

  def default_header_options
    {
      hover: true,
      seal: false
    }
  end

  def fr_box_header(title, type, options)
    content_tag(:div, class: "fr-seal-block fr-seal-block-header") do
      content_tag(:div, class: "fr-seal-content") do
        description = options[:hover] ? fr_box_header_description(type, options[:seal]) : "".html_safe

        content_tag(:h6, title) +
          description
      end
    end
  end

  def fr_box_header_description(type, seal)
    content_tag(:div, class: "row fr-seal-meta") do
      html = seal ? fr_box_seal(type) : "".html_safe

      html +
      content_tag(:div, class: "fr-seal-desc") do
        content_tag(:p, description_by_type(type))
      end
    end
  end

  def fr_box_seal(type)
    content_tag(:div, class: "fr-seal-stamp") do
      content_tag(:span, "", class: "fr-stamp")
    end
  end

  def fr_box_footer(title, type)
    content_tag(:div, class: "fr-seal-block fr-seal-block-footer") do
      content_tag(:h6, title)
    end
  end

  private

  def css_class_by_type(type)
    case type
    when :official
      "fr-box-official"
    when :doc_details
      "fr-box-official-alt"
    when :reg_gov_docket_info, :enhanced
      "fr-box-enhanced"
    when :public_inspection
      "fr-box-public-inspection"
    end
  end

  def description_by_type(type)
    case type
    when :official
      "This box contains the official document as published by the Office of the Federal Register"
    when :doc_details
      "Metadata about the official document that appears to the left of this box"
    when :reg_gov_docket_info
      "This box contains content about this document retrieved from Regulations.gov in order to provide you with more context for this document. The content in this box has not been published in the Federal Register and is only provided for your convenience."
    end
  end
end
