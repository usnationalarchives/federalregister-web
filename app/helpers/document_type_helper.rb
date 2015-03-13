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

  def document_type_icon(type)
    document_type = DocumentType.new(type)
    content_tag(:div,
      class: "#{document_type.icon_wrapper_class('mini')} tooltip",
      "data-tooltip" => document_type.type) do
        content_tag(:span, '', class: document_type.icon_class)
      end
  end

  def document_type_icon_with_count(type, count)
    document_type = DocumentType.new(type)
    content_tag(:i,
      class: "icon-fr2 icon-fr2-#{document_type.icon_class} rule_type with-tooltip-s",
      "data-tooltip" => document_type.display_type ) do #TODO: Get rid of unnecessary do loop
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
