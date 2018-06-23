class PresidentialDocumentsIndexPresenter
  DOCUMENT_TYPES = %w(executive_order proclamation other_presidential_document)

  def name
    'Presidential Documents'
  end

  def description
    'Content needed'
  end

  def subtypes
    @subtypes ||= DOCUMENT_TYPES.map do |doc_type|
      PresidentialDocumentType.find(doc_type)
    end
  end

  def fr_content_box_type
    :reader_aid
  end

  def fr_content_box_title
    name
  end

  def description_for(doc_type)
    I18n.t("presidential_documents.#{doc_type.type.pluralize}.description").html_safe
  end

  def short_description_for(doc_type)
    I18n.t("presidential_documents.#{doc_type.type.pluralize}.short_description").html_safe
  end

  def counts_for(doc_type)
    counts_by_type[doc_type]
  end

  def counts_by_type
    return @counts_by_type if @counts_by_type

    counts_by_type = {}
    PresidentialDocumentsIndexPresenter::DOCUMENT_TYPES.each{|t| counts_by_type[t] = {}}

    President.all.reverse.each do |president|
      facets = PresidentialDocumentsFacet.search(
        conditions: {
          president: president.identifier,
          type: "PRESDOCU",
        }
      )

      facets.each do |facet|
        case facet.slug
        when 'executive_order', 'proclamation'
          type = facet.slug
        else
          type = 'other_presidential_document'
        end

        if type == 'other_presidential_document'
          count = counts_by_type[type][president].to_i + facet.count
        else
          count = facet.count
        end

        counts_by_type[type].merge!(president => count)
      end
    end

    @counts_by_type = counts_by_type
  end
end
