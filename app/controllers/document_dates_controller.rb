class DocumentDatesController < ApplicationController
  skip_before_filter :authenticate_user!

  def document_dates_navigation
    @doc_presenter = DocumentIssuePresenter.new("Mon, 9 Mar 2015".to_date)
    render template: 'document_dates/document_dates_navigation', layout: false
  end

end
