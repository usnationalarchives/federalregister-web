class TableOfContentsRegularFilingsPresenter < TableOfContentsPublicInspectionPresenter
  def url_type
    "regular_filing"
  end

  private

  def query_conditions
    if date == PublicInspectionDocumentIssue.current.publication_date
      QueryConditions::PublicInspectionDocumentConditions.regular_filing
    else
      QueryConditions::PublicInspectionDocumentConditions.
        regular_filings_available_on(date)
    end
  end
end
