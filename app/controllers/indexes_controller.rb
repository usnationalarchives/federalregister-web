class IndexesController < ApplicationController
  skip_before_filter :authenticate_user!

  def year_agency
    #B.C. TODO: Rescue if agency/year is invalid.
    year = params[:year]
    agency_slug = params[:agency_slug]
    @presenter = FrIndexAgencyPresenter.new(year, agency_slug)
  end

  def year
    raise ActiveRecord::RecordNotFound if params[:year].match(/\A(19|20)\d{2}\z/).nil?
    cache_for 1.day
    @presenter = FrIndexIndexPagePresenter.new(params[:year])
  end

  def select_index_year
    redirect_to index_year_path(params.delete(:year) || Date.today.year)
  end

end
