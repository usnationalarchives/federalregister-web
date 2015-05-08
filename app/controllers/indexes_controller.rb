class IndexesController < ApplicationController
  skip_before_filter :authenticate_user!

  def year_agency
    #B.C. TODO: Rescue if agency/year is invalid.
    year = params[:year]
    agency_slug = params[:agency_slug]
    @presenter = FrIndexAgencyPresenter.new(year, agency_slug)
  end

  def year
    cache_for 1.day
    @presenter = FrIndexIndexPagePresenter.new(params[:year])
    #B.C. TODO: Rescue if agency/year is invalid.
  end

  def select_index_year
    redirect_to index_year_path(params.delete(:year) || Date.today.year)
  end

end
