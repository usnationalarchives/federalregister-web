module DocumentTypeHelper
  def my_fr_document_filters
    filters = []
    document_types.each_with_index do |(type, label), index|
      filters <<  content_tag(:li,
                              :class => "doc_#{type} #{position_class(index, document_types.length)}",
                              'data-filter-doc-type' => type,
                              'data-filter-doc-type-display' => label) do
                    content_tag(:span, '',
                                :class => "icon-fr2 icon-fr2-#{label.downcase.gsub(' ', '_')}",
                                'aria-hidden' => true)
                  end
    end

    filters.join("\n").html_safe
  end

  def document_type_icon(type, options={})
    document_type = type.is_a?(DocumentType) ? type : DocumentType.new(type)
    content_tag(:div,
      class: "#{document_type.icon_wrapper_class(options[:size])} tooltip",
      "data-tooltip" => document_type.type) do
        content_tag(:span, '', class: document_type.icon_class)
    end
  end

  def simple_document_type_icon(type, options={})
    document_type = type.is_a?(DocumentType) ? type : DocumentType.new(type)
    icon_class = options.fetch(:icon_class, '')

    content_tag(
      :span,
      '',
      class: "#{document_type.icon_class} #{document_type.icon_wrapper_class(options[:size])} #{icon_class} cj-tooltip",
      "data-tooltip" => document_type.type
    )
  end

  def suggested_search_icon_helper(type)
    document_type = DocumentType.new(type)
    content_tag(:div,
      class: "#{document_type.icon_wrapper_class} tipsy original-title") do
        content_tag(:h2,
          content_tag(:span, '', class: "icon-fr2 icon-doctype icon-fr2-#{document_type.granule_class}")
          )
    end
  end

  private

  def document_types
    [
      ['notice', 'Notice'],
      ['proposed_rule', 'Proposed Rule'],
      ['rule', 'Rule'],
      ['presidential_document', 'Presidential Document'],
      ['correction', 'Correction']
    ]
  end

  def position_class(index, array_length)
    case index
    when 0
      'first'
    when array_length - 1
      'last'
    else
      ''
    end
  end
end
