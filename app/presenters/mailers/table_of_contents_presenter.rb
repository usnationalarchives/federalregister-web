class Mailers::TableOfContentsPresenter < TableOfContentsPresenter
  attr_reader :table_of_contents_data, :date, :filter_to_documents

  def document_partial
    'document_issues/mailer/document_details'
  end
end
