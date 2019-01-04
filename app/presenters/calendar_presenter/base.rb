class CalendarPresenter::Base
  attr_reader :date, :options, :published_dates, :view

  def initialize(date, published_dates, view_context, options={})
    @date = date

    # only allow certain table classes as input
    options[:table_class] = %w(cal_first cal_last).include?(options[:table_class]) ? options[:table_class] : nil
    @options = options

    @published_dates = published_dates
    @view = view_context
  end

  def year
    date.year
  end

  def month
    date.month
  end

  # ugly hack to punch in data attributes
  def table_class
    "calendar #{options[:table_class]}\" data-calendar-year=\"#{year}\" data-calendar-month=\"#{month}\" data-year-start=\"1994\" data-year-end=\"#{Time.now.year}\" data-year-select=\"#{year_select?}\""
  end

  def previous_month_text
    view.link_to(
      '&laquo; Prev'.html_safe,
      previous_month_path({
        table_class: options[:table_class],
        year_select: year_select?
      }),
      class: "nav"
    )
  end

  def next_month_text
    if date.months_since(1) <= issue.current.publication_date
      view.link_to(
        'Next &raquo;'.html_safe,
        next_month_path({
          table_class: options[:table_class],
          year_select: year_select?
        }),
        :class => 'nav'
      )
    else
      ""
    end
  end

  def current_issue_is_late?
    if issue == PublicInspectionDocumentIssue
      false
    else
      issue.current_issue_is_late?
    end
  end

  def current_issue_date
    issue.current.publication_date
  end

  def current_date
    Chronic.parse(options[:current_date]).try(:to_date)
  end

  def holiday(date)
    Holiday.find_by_date(date)
  end

  def year_select?
    ActiveRecord::Type::Boolean.new.type_cast_from_database(
      options[:year_select]
    )
    # TODO: Rails5 change to: ActiveRecord::Type::Boolean.new.cast(options[:year_select])
  end
end
