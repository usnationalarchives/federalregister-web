class AgenciesController < ApplicationController
  skip_before_filter :authenticate_user!
  def index
    #cache?
    @agencies = FederalRegister::Agency.all
    @presenter = AgenciesPresenter.new(@agencies)
  end

  def show
    @presenter = AgenciesPresenter.new(FederalRegister::Agency.all)
    @agency = @presenter.agency(params[:id])
    respond_to do |wants|
      wants.html do
        @public_inspection_search_results = FederalRegister::PublicInspectionDocument.search(
          conditions: {
            agency_ids: [@agency.id]
          },
          per_page: 250,
          order: 'newest',
        )

        @public_inspection_documents = @public_inspection_search_results.
          map{|document| DocumentDecorator.decorate(document)}

        @document_search_results = FederalRegister::Article.search(
          conditions: {
            agency_ids: [@agency.id]
          },
          order: 'newest',
          per_page: 40
        )

        @documents = @document_search_results.
          map{|document| DocumentDecorator.decorate(document)}

        @significant_documents_search_results = FederalRegister::Article.search(
          conditions: {
            agency_ids: [@agency.id],
            significant: '1',
            publication_date: {
              gte: 3.months.ago.to_date.to_s
            }
          },
          order: 'newest',
          per_page: 40
        )
        @significant_documents = @significant_documents_search_results.
          map{|document| DocumentDecorator.decorate(document)}
      # @comments_closing = @agency.entries.comments_closing
      # @comments_opening = @agency.entries.comments_opening
      end

      wants.rss do
        base_url = 'https://www.federalregister.gov/articles/search.rss?'
        options = "conditions[agency_ids]=#{@agency.id}&order=newest.com"
        redirect_to base_url + options, status: :moved_permanently
      end
    end
  end


  # RW: Old
  def significant_entries
    cache_for 1.day
    @presenter = AgenciesPresenter.new(FederalRegister::Agency.all)
    @agency = @presenter.agency(params[:id])
    
    respond_to do |wants|
      wants.rss do
        base_url = 'https://www.federalregister.gov/articles/search.rss?'
        options = "conditions[agency_ids]=#{@agency.id}&order=newest.com&conditions[significant]=1"
        redirect_to base_url + options, status: :moved_permanently
      end
    end
  end
end
