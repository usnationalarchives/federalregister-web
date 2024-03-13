class AgenciesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    cache_for 1.day

    @presenter = AgenciesPresenter.new
  end

  def show
    cache_for 1.day

    @presenter = AgencyPresenter.new(params[:id])

    respond_to do |wants|
      wants.html
      wants.rss {
        redirect_to "#{Settings.services.fr.web.base_url}/documents/search.rss?conditions[agencies][]=#{@presenter.agency.slug}",
          status: :moved_permanently
      }
    end
  end

  def suggestions
    agencies = Agency.suggestions(params[:term])
    render :json => agencies.map{|a|
      {slug: a.slug, name: a.name_and_short_name, url: a.url}
    }
  end

  def significant_entries
    cache_for 1.day
    @presenter = AgencyPresenter.new(params[:id])

    respond_to do |wants|
      wants.rss do
        redirect_to "#{Settings.services.fr.web.base_url}/documents/search.rss?conditions[agencies][]=#{@presenter.agency.slug}&conditions[significant]=1",
          status: :moved_permanently
      end
    end
  end
end
