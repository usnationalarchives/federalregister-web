class IssuesController < ApplicationController
  skip_before_filter :authenticate_user!
  layout false, only: :summary

  def summary
    @doc_presenter = DocumentIssuePresenter.new(
      DocumentIssue.current.publication_date
    )
    @pi_presenter = PublicInspectionIssuePresenter.new(
      PublicInspectionDocumentIssue.current.publication_date
    )
  end
end
