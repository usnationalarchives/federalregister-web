module DocumentTypeHelper
  def my_fr_document_filters
    filters = []
    document_types.each_with_index do |(type, label), index|
      filters <<  content_tag(:li, 
                              :class => "doc_#{type} #{position_class(index, document_types.length)}",
                              'data-filter-doc-type' => type,
                              'data-filter-doc-type-display' => label) do
                    tag(:span,
                                :class => "icon-fr2 icon-fr2-#{label.downcase.gsub(' ', '_')}",
                                'aria-hidden' => true)
                  end
    end

    filters.join("\n").html_safe
  end

  private

  def document_types
    [
      ['notice', 'Notice'],
      ['prorule', 'Proposed Rule'],
      ['rule', 'Rule'],
      ['presdocu', 'Presidential Document'],
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
