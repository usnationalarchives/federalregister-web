class AgenciesController < ApplicationController
  skip_before_filter :authenticate_user!
  layout false, only: [:navigation, :explore_agencies]

  def index
    cache_for 1.day

    @presenter = AgenciesPresenter.new
  end

  def show
    cache_for 1.day

    @presenter = AgencyPresenter.new(params[:id])

    respond_to do |wants|
      wants.html
      wants.rss do
        base_url = 'https://www.federalregister.gov/articles/search.rss?'
        options = "conditions[agency_ids]=#{@presenter.agency.id}&order=newest.com"
        redirect_to base_url + options, status: :moved_permanently
      end
    end
  end

  def suggestions
    agencies = Agency.suggestions(params[:term])
    render :json => agencies.map{|a|
      {id: a.id, name: a.name_and_short_name, url: a.url}
    }
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

  def navigation
    cache_for 1.day
    @presenter = Facets::AgenciesPresenter.new
  end

  def explore_agencies
    cache_for 1.day
    @presenter = Facets::AgenciesPresenter.new
  end
end
