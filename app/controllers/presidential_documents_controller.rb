class PresidentialDocumentsController < ApplicationController
  skip_before_action :authenticate_user!

  def homepage
    cache_for 1.day
    @presenter = PresidentialDocumentsHomepagePresenter.new
    render layout: false
  end

  def index
    cache_for 1.day
    @presenter = PresidentialDocumentsIndexPresenter.new
  end

  def show
    cache_for 1.day
    @presenter = PresidentialDocumentsPresenter.new(
      presidential_document_params.merge(view_context: view_context)
    )

    @presidents = President.all.sort_by(&:starts_on).reverse
  end

  def by_president_and_year
    cache_for 1.day
    @presenter = PresidentialDocumentsDispositionTablePresenter.new(
      presidential_document_params.merge(view_context: view_context)
    )

    raise ActiveRecord::RecordNotFound unless @presenter.presidential_documents_collection.results.present?
  end

  private

  def presidential_document_params
    params.permit(:president, :type, :year)
  end
end
