class PresidentialDocumentsDispositionTablePresenter < PresidentialDocumentsPresenter
  def name
    presidential_document_type.name.pluralize
  end

  def description
    I18n.t("presidential_documents.#{type}.tables", president: President.first.full_name).html_safe
  end

  def current_page?(president, presidential_document_collection)
    president == self.president && presidential_document_collection.year == year.to_i
  end

  def valid_year?
    (1936..Date.current.year).include? year.to_i
  end

end
