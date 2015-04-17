class PublicInspectionDocumentIssuesController < ApplicationController
  skip_before_filter :authenticate_user!

  def show
    if PublicInspectionDocumentIssue.available_on(parse_date_from_params)
      raise ActiveRecord::RecordNotFound
    else
      @pi_presenter = PublicInspectionIssuePresenter.new(parse_date_from_params)
      @special_filings_presenter = TableOfContentsSpecialFilingsPresenter.new(parse_date_from_params)
      @regular_filings_presenter = TableOfContentsRegularFilingsPresenter.new(parse_date_from_params)
    end
  end

end

