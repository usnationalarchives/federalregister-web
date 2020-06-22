class PublicInspectionDocumentIssuesController < ApplicationController
  skip_before_action :authenticate_user!
  layout false, only: [:by_month, :navigation]

  def show
    cache_for 1.day
    unless PublicInspectionDocumentIssue.available_for?(parse_date_from_params)
      raise ActiveRecord::RecordNotFound
    end

    build_pil_presenters(parse_date_from_params)
  end

  def search
    date = Chronic.parse(params[:date]).try(:to_date)

    if date
      redirect_to public_inspection_issue_path(date)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def current
    cache_for 1.day

    build_pil_presenters(
      PublicInspectionDocumentIssue.current.publication_date,
      current_issue: true
    )

    render :show
  end

  # legacy
  def public_inspection
    redirect_to current_public_inspection_issue_path,
      status: :moved_permanently
  end

  def by_month
    cache_for 1.day

    date = parse_date_from_params

    document_dates = PublicInspectionDocumentIssue.for_month(date).
      select{|result| result.has_documents?}.
      map{|doc_issue| doc_issue.slug.to_date }

    options = {
      current_date: params[:current_date],
      table_class: params[:table_class],
      year_select: params[:year_select] || true
    }

    @presenter = CalendarPresenter::PublicInspection.new(
      date, document_dates, view_context, options
    )

    render "issues/calendar"
  end

  private

  def build_pil_presenters(date, issue_options={})
    @presenter = PublicInspectionIssuePresenter.new(date, issue_options)
    @special_filings_presenter = TableOfContentsSpecialFilingsPresenter.new(date)
    @regular_filings_presenter = TableOfContentsRegularFilingsPresenter.new(date)
  end
end
