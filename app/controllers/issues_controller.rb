class IssuesController < ApplicationController
  skip_before_action :authenticate_user!
  layout false, only: :summary

  def summary
    cache_for 1.day

    @home = params[:path] == "home"
    @pi = params[:path] == "pi"

    begin
      date = Date.parse(params[:date]) unless @home
    rescue NoMethodError
      # only want to rescue bad date errors here
      raise ActiveRecord::RecordNotFound
    end

    unless @pi
      @doc_presenter = DocumentIssuePresenter.new(
        @home ? DocumentIssue.current.try(:publication_date) : date
      )
    end

  if @home || @pi
      @pi_presenter = PublicInspectionIssuePresenter.new(
        @home ? PublicInspectionDocumentIssue.current.try(:publication_date) : date
      )
    end
  end
end
