class IndexesController < ApplicationController
  skip_before_filter :authenticate_user!

  def year_agency
    year = params[:year]
    agency_slug = params[:agency_slug]
    @presenter = FrIndexAgencyPresenter.new(year, agency_slug)
  end

end
