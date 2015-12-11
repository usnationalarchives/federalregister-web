class PublicInspectionDocumentIssuesController < ApplicationController
  skip_before_filter :authenticate_user!

  def show
    cache_for 1.day
    unless PublicInspectionDocumentIssue.available_for?(parse_date_from_params)
      raise ActiveRecord::RecordNotFound
    end

    build_pil_presenters(parse_date_from_params)
  end

  def current
    cache_for 1.day

    build_pil_presenters(PublicInspectionDocumentIssue.current.publication_date)

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
      table_class: params[:table_class] || "calendar"
    }

    # if params[:current_date]
    #   @current_date = params[:current_date].is_a?(Date) ? params[:current_date] : Date.parse(params[:current_date])
    # end

    @presenter = CalendarPresenter::PublicInspection.new(
      date, document_dates, view_context, options
    )

    render "issues/calendar", :layout => false
  end

  def navigation
    cache_for 1.day

    @pi_presenter = PublicInspectionIssuePresenter.new(
      PublicInspectionDocumentIssue.current.publication_date
    )
  end

  private

  def build_pil_presenters(date)
    @presenter = PublicInspectionIssuePresenter.new(date)
    @special_filings_presenter = TableOfContentsSpecialFilingsPresenter.new(date)
    @regular_filings_presenter = TableOfContentsRegularFilingsPresenter.new(date)
  end
end
