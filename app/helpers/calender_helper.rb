module CalenderHelper
  def document_calendar_esi_for(date, options={})
    esi document_issues_by_month_path(
      date.year,
      date.month,
      options
    )
  end

  def public_inspection_calendar_esi_for(date, options={})
    esi public_inspection_issues_by_month_path(
      date.year,
      date.month,
      options
    )
  end

  def document_calendar_for(date, options={})
    date = date.beginning_of_month
    options = {year_select: true}.merge(options)

    document_dates = DocumentIssue.for_month(date).
      select{|result| result.has_documents?}.
      map{|result| result.slug.to_date}

    view_context = options.delete(:view_context)
    @presenter = CalendarPresenter::Document.new(
      date, document_dates, view_context, options
    )

    render template: 'issues/calendar'
  end

  def public_inspection_calendar_for(date, options={})
    date = date.beginning_of_month
    options = {year_select: true}.merge(options)

    document_dates = PublicInspectionDocumentIssue.for_month(date).
      select{|result| result.has_documents?}.
      map{|doc_issue| doc_issue.slug.to_date}

    view_context = options.delete(:view_context)
    @presenter = CalendarPresenter::PublicInspection.new(
      date, document_dates, view_context, options
    )

    render template: 'issues/calendar'
  end
end
