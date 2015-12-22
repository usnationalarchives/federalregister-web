class CalendarPresenter::PublicInspection < CalendarPresenter::Base
  def issue
    PublicInspectionDocumentIssue
  end

  def previous_month_path(options={})
    view.public_inspection_issues_by_month_path(
      date.months_ago(1).year,
      date.months_ago(1).month,
      options
    )
  end

  def next_month_path(options={})
    view.public_inspection_issues_by_month_path(
      date.months_since(1).year,
      date.months_since(1).month,
      options
    )
  end

  def issue_path(date)
    view.public_inspection_issue_path(date)
  end

  def should_have_an_issue?(date)
    issue.available_for?(date)
  end
end
