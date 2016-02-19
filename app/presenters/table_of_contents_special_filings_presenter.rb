class TableOfContentsSpecialFilingsPresenter < TableOfContentsPublicInspectionPresenter
  def url_type
    "special_filing"
  end

  private

  def query_conditions
    if date == PublicInspectionDocumentIssue.current.publication_date
      QueryConditions::PublicInspectionDocumentConditions.special_filing
    else
      QueryConditions::PublicInspectionDocumentConditions.
        special_filings_available_on(date)
    end
  end
end
