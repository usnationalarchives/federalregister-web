module CalendarHelper
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
end
