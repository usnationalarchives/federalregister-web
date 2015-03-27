class IssuesController < ApplicationController
  skip_before_filter :authenticate_user!
  layout false, only: :summary

  def summary
    @doc_presenter = DocumentIssuePresenter.new(Date.current)
    @pi_presenter = PublicInspectionPresenter.new(Date.current)
  end
end
