class PresidentialDocumentsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    cache_for 1.day
    @presenter = PresidentialDocumentsIndexPresenter.new
  end

  def show
    cache_for 1.day
    @presenter = PresidentialDocumentsPresenter.new(
      presidential_document_params.merge(view_context: view_context)
    )

    @presidents = @presenter.presidents
  end

  def by_president_and_year
    cache_for 1.day

    president = president_from_params
    raise ActiveRecord::RecordNotFound unless president

    @presenter = PresidentialDocumentsDispositionTablePresenter.new(
      presidential_document_params.merge(
        president: president,
        view_context: view_context
      )
    )

    raise ActiveRecord::RecordNotFound unless @presenter.valid_year? && @presenter.presidential_documents_collection.results.present?
  end

  private

  def presidential_document_params
    params.permit(:president, :type, :year)
  end

  def president_from_params
    President.
      in_office_on_year(presidential_document_params[:year].to_i).
      find{|president|
        president.identifier == presidential_document_params[:president]}
  end
end
