class PublicInspectionDocumentsController < ApplicationController
  skip_before_filter :authenticate_user!
  layout false, only: :navigation



  def navigation
    cache_for 1.day
    @pi_presenter = PublicInspectionIssuePresenter.new(
      PublicInspectionDocumentIssue.current.publication_date
    )
  end
end
