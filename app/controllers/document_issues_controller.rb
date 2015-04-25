class DocumentIssuesController < ApplicationController
  skip_before_filter :authenticate_user!
  layout false, only: :navigation

  def show
    cache_for 1.day
    parsed_date = parse_date_from_params

    if DocumentIssue.published_on(parsed_date).empty?
      raise ActiveRecord::RecordNotFound
    else
      @presenter = TableOfContentsPresenter.new(parsed_date)
      @doc_presenter = DocumentIssuePresenter.new(parsed_date)
    end
  end

  def navigation
    cache_for 1.day
    @doc_presenter = DocumentIssuePresenter.new(
      DocumentIssue.current.publication_date
    )
  end
end
