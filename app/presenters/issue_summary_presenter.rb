class IssueSummaryPresenter
  attr_reader :date, :location

  def initialize(location:, date: nil)
    @date = date
    @location = location
  end

  def doc_issue_presenter
    DocumentIssuePresenter.new(
      date || DocumentIssue.current.try(:publication_date),
      home: home?
    )
  end

  def issue_late?
    DocumentIssue.current_issue_is_late?
  end

  def pil_issue_presenter
    PublicInspectionIssuePresenter.new(
      date || PublicInspectionDocumentIssue.current.try(:publication_date),
      home: home?
    )
  end

  def display_document_issue_summary?
    return false if pil? || issue_late?
    true
  end

  def display_late_document_issue_notification?
    return true if home? && issue_late?
    false
  end

  def display_pil_issue_summary?
    return true if home? || pil?
    false
  end

  def home?
    location == "home"
  end

  def pil?
    location == "pi"
  end
end
