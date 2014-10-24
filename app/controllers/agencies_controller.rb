class AgenciesController < ApplicationController
  skip_before_filter :authenticate_user!
  def index
    #cache?
    @agencies = FederalRegister::Agency.all
    @presenter = AgenciesPresenter.new(@agencies, params[:id])
  end

  def show
    @presenter = AgenciesPresenter.new(FederalRegister::Agency.all, params[:id])
    @agency = @presenter.agency
    respond_to do |wants|
      wants.html
      # @comments_closing = @agency.entries.comments_closing
      # @comments_opening = @agency.entries.comments_opening

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
