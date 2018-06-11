class PresidentialDocumentsDispositionTablePresenter < PresidentialDocumentsPresenter
  def name
    "#{presidential_document_type.name} Disposition Table"
  end

  def description
    "Disposition Tables contain information about Presidential Documents beginning with those signed by #{President.first.full_name} and are arranged according to Presidential administration and year of signature.
    The tables are compiled and maintained by the Office of the Federal Register editors."
  end

  def fr_content_box_title
    "#{year} #{president.full_name} #{presidential_document_type.name} Disposition Table"
  end

  def current_page?(president, presidential_document_collection)
    president == self.president && presidential_document_collection.year == year.to_i
  end
end
