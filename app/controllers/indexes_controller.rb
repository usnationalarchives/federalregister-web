class IndexesController < ApplicationController
  skip_before_filter :authenticate_user!

  def year_agency
    cache_for 1.day
    @presenter = FrIndexAgencyPresenter.new(params[:year], params[:agency_slug])
  end

  def year
    cache_for 1.day
    @presenter = FrIndexPresenter.new(params[:year])
  end
end
