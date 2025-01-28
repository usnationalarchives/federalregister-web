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
    @presenter = PresidentialDocumentsDispositionTablePresenter.new(
      presidential_document_params.tap do |p_params|
        president = President.
          in_office_on_year(p_params[:year].to_i).
          find do |president|
            president.identifier == p_params[:president]
          end

        p_params[:president] = president
      end.
      merge(view_context: view_context)
    )

    raise ActiveRecord::RecordNotFound unless @presenter.valid_year? && @presenter.presidential_documents_collection.results.present?
  end

  private

  def presidential_document_params
    params.permit(:president, :type, :year)
  end
end
