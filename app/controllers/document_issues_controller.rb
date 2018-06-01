class DocumentIssuesController < ApplicationController
  skip_before_filter :authenticate_user!
  layout false, only: [:by_month, :navigation]

  def show
    cache_for 1.day

    parsed_date = parse_date_from_params

    if DocumentIssue.published_on(parsed_date).has_documents?
      @presenter = TableOfContentsPresenter.new(parsed_date)
      @doc_presenter = DocumentIssuePresenter.new(parsed_date, documents: @presenter.documents)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def search
    cache_for 1.day

    date = Chronic.parse(params[:date]).try(:to_date)

    if date
      redirect_to document_issue_path(date)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def current
    cache_for 1.day

    date = DocumentIssue.current.publication_date
    @presenter = TableOfContentsPresenter.new(date)
    @doc_presenter = DocumentIssuePresenter.new(date, current_issue: true)

    render :show
  end

  def by_month
    cache_for 1.day

    date = parse_date_from_params

    document_dates = DocumentIssue.for_month(date).
      select{|result| result.has_documents?}.
      map{|result| result.slug.to_date}

    options = {
      current_date: params[:current_date],
      table_class: params[:table_class],
      year_select: params[:year_select] || true
    }

    @presenter = CalendarPresenter::Document.new(
      date, document_dates, view_context, options
    )

    render "issues/calendar"
  end
end
