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
    @doc = DocumentDecorator.decorate(FederalRegister::Document.find(doc_num, fields: ["html_url", "publication_date"]))
  end

  def corrected_documents
    return @corrected_documents if @corrected_documents

    @corrected_documents = corrections.map do |correction|
      doc_num = correction.split('documents/').last.split('.').first
      DocumentDecorator.decorate(FederalRegister::Document.find(doc_num, fields: ["document_number", "html_url", "publication_date"]))
    end
  end
end
