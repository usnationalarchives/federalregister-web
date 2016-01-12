module DocumentDecorator::Corrections
  def corrections?
    correction_of.present? || corrections.present?
  end

  def republication?
    document_number =~ /^R/
  end

  def correction_of_document
    return @doc if @doc

    doc_num = correction_of.split('documents/').last.split('.').first
    @doc = DocumentDecorator.decorate(
      Document.find(doc_num, fields: ["html_url", "publication_date"])
    )
  end

  def corrected_documents
    return @corrected_documents if @corrected_documents

    @corrected_documents = corrections.map do |correction|
      doc_num = correction.split('documents/').last.split('.').first
      DocumentDecorator.decorate(
        Document.find(doc_num, fields: ["document_number", "html_url", "publication_date"])
      )
    end
  end

  def corrected_by
    corrected_documents.map do |d|
      h.content_tag(:dd, h.link_to(d.document_number, d.html_url))
    end.join("\n").html_safe
  end

  def corrects
    h.link_to(
      correction_of_document.document_number,
      correction_of_document.html_url
    )
  end
end
