module CalendarHelper
  def document_calendar_esi_for(date, options={})
    table_class = options.delete(:table_class)

    esi document_issues_by_month_path(
      date.year,
      date.month,
      table_class: "no_select #{table_class}"
    )
  end
end
