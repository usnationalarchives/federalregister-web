class IndexesController < ApplicationController
  skip_before_filter :authenticate_user!

  def year_agency
    #TODO: Rescue if agency/year is invalid.
    year = params[:year]
    agency_slug = params[:agency_slug]
    @presenter = FrIndexAgencyPresenter.new(year, agency_slug)
  end

  def year
    @presenter = FrIndexIndexPagePresenter.new(params[:year])
    #TODO: Rescue if agency/year is invalid.
  end

end
