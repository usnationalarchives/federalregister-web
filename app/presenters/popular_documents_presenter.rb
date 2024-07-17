class PopularDocumentsPresenter
  def popular_documents
    PopularDocument.popular.sort_by(&:comment_count)
      .reverse.first(PopularDocument::POPULAR_DOCUMENT_COUNT)
  end
end
