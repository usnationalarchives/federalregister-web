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

    begin
      @date = Date.parse("#{params[:year]}-#{params[:month]}-01")
    rescue ArgumentError
      raise ActiveRecord::RecordNotFound
    end

    @table_class = "calendar"
    @public_inspection_dates = PublicInspectionDocumentIssue.search(
      conditions:
        {publication_date:
          {gte: @date.beginning_of_month.to_s(:iso),
           lte: @date.end_of_month.to_s(:iso)
          }
        }
    ).map{|doc_issue|doc_issue.slug.to_date }

    if params[:current_date]
      @current_date = params[:current_date].is_a?(Date) ? params[:current_date] : Date.parse(params[:current_date])
    end

    render :layout => false
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
