class DocumentIssuesController < ApplicationController
  skip_before_filter :authenticate_user!

  def show
    parsed_date = parse_date_from_params

    if DocumentIssue.published_on(parsed_date).empty?
      raise ActiveRecord::RecordNotFound
    else
      @presenter = TableOfContentsPresenter.new(parsed_date)
      @doc_presenter = DocumentIssuePresenter.new(parsed_date)
    end
  end
end
