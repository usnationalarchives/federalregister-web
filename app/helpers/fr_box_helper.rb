module FrBoxHelper

  def fr_box(title, type, options={}, &block)
    box_type = options.fetch(:box_type) { :large }
    box_options = options.fetch(:box_html) { Hash.new }
    header_options = options.fetch(:header) { Hash.new }
    content_block_options = options.fetch(:content_block_html) { Hash.new }

    content_tag(:div, class: "fr-box #{css_class_by_type(type)} #{box_options[:class]}", role: box_options[:role]) do
      fr_box_header(title, type, box_type, default_header_options.merge!(header_options)) +
        content_tag(:div, capture(&block), class: "content-block #{content_block_options[:class]}") +
        fr_box_footer(title, type)
    end
  end

  def fr_box_small(title, type, options={}, &block)
    #inject the small box class
    if options[:box_html] && options[:box_html][:class]
      options[:box_html][:class] += "fr-box-small"
    else
      options.deep_merge!(
        box_html: {class: "fr-box-small"},
        box_type: :small
      )
    end

    fr_box(title, type, options, &block)
  end

  def default_header_options
    {
      hover: true,
      seal: false
    }
  end

  def fr_box_header(title, type, box_type, options)
    content_tag(:div, class: "fr-seal-block fr-seal-block-header") do
      content_tag(:div, class: "fr-seal-content") do
        description = options[:hover] ? fr_box_header_description(type, box_type, options) : "".html_safe

        content_tag(:h6, title) +
          description
      end
    end
  end

  def fr_box_header_description(type, box_type, options={})
    col_span = box_type == :small ? 12 : 9

    content_tag(:div, class: "row fr-seal-meta") do
      html = options[:seal] ? fr_box_seal(type) : "".html_safe

      html +
      content_tag(:div, class: "fr-seal-desc col-md-#{col_span} col-xs-#{col_span}") do
        if options[:description]
          options[:description].html_safe
        else
          content_tag(:p, description_by_type(type).html_safe)
        end
      end
    end
  end

  def fr_box_seal(type)
    content_tag(:div, class: "fr-seal-stamp col-md-3 col-xs-3") do
      content_tag(:span, "", class: "fr-stamp icon-fr2 #{stamp_icon_class_by_type(type)}")
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
    when :official, :official_toc
      "fr-box-official"
    when :official_doc_details
      "fr-box-official-alt"
    when :reg_gov_docket_info, :enhanced
      "fr-box-enhanced"
    when :public_inspection
      "fr-box-public-inspection"
    when :public_inspection_doc_details
      "fr-box-public-inspection-alt"
    when :reader_aid
      "fr-box-reader-aid"
    when :disabled
      "fr-box-unavailable"
    end
  end

  def description_by_type(type)
    case type
    when :official
      "This is the official document as published in the <em>Federal Register</em>."
    when :official_doc_details
      "Information about this document as published in the <em>Federal Register</em>."
    when :official_toc
      "This is the official table of contents as published in the <em>Federal Register</em>."
    when :reg_gov_docket_info
      "Relevant information about this document from Regulations.gov provides additional context. This information is not part of the official <em>Federal Register</em> document."
    when :public_inspection
      "Public Inspection documents are unpublished documents. Click #{link_to 'here', public_inspection_learn_path} to learn more about Public Inspection."
    when :public_inspection_doc_details
      "Additional information about this Public Inspection document."
    when :reader_aid
      "Reader Aids help people use FederalRegister.gov and understand the federal rulemaking process. Reader Aids information is not published in the <em>Federal Register</em>."
    end
  end

  def stamp_icon_class_by_type(type)
    case type
    when :official, :official_toc
      "icon-fr2-NARA1985Seal"
    when :public_inspection
      "icon-fr2-stop-hand"
    end
  end
end
