class TableOfContentsRegularFilingsPresenter < TableOfContentsPublicInspectionPresenter
  def url_type
    "regular_filing"
  end

  def filing_type
    'regular'
  end
end
