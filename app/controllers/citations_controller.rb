class CitationsController < ApplicationController
  skip_before_filter :authenticate_user!

  CFR_REGEXP = /(\d+)-CFR-(\d+)(?:\.(\d+))?/

  def cfr
    title, part, section = params[:citation].match(CFR_REGEXP)[1..3]
    redirect_to fdsys_cfr_url(title, part, section)
  end
end
