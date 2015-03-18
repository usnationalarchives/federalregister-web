class DocumentDatesController < ApplicationController
  skip_before_filter :authenticate_user!

  def document_dates_navigation
    @doc_presenter = DocumentIssuePresenter.new(Date.current)
    @pi_presenter = PublicInspectionPresenter.new(Date.current)
    render template: 'document_dates/document_dates_navigation', layout: false
  end

end
