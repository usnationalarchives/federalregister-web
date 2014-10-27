class SectionsController < ApplicationController
  skip_before_filter :authenticate_user!

  def navigation
    render "esi/layout/navigation/sections",
      layout: false
  end
end
