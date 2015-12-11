class CalendarPresenter::Document < CalendarPresenter::Base
  def issue
    DocumentIssue
  end

  def previous_month_path
    view.document_issues_by_month_path(
      date.months_ago(1).year,
      date.months_ago(1).month
    )
  end

  def next_month_path
    view.document_issues_by_month_path(
      date.months_since(1).year,
      date.months_since(1).month
    )
  end

  def issue_path(date)
    view.document_issue_path(date)
  end
end
