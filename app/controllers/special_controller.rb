class SpecialController < ApplicationController
  skip_before_action :authenticate_user!
  layout false, except: :home

  def csrf_protection
  end

  def home
    cache_for 1.day
  end

  def robots
    cache_for 1.day
    render 'robots', layout: false, content_type: 'text/plain'
  end

  def status
    render plain: "Serving requests (MyFR)"
  end

  # used by k8s probe to know when container
  # is ready / able to receive request
  def alive
    render json: {}.to_json, status: :ok
  end

  def site_notifications
    cache_for 1.day
    raw_response = HTTParty.get(
      "#{Settings.services.fr.api_core.internal_base_url}/site_notifications/#{params[:identifier]}"
    )
    if (raw_response.code == 200) && raw_response.parsed_response.present?
      @response = raw_response.parsed_response
    else
      head :ok
    end
  end

  def footer
    cache_for 1.day

    @reader_aids_sections = ReaderAidsPresenter::Base.new.sections
    @my_fr_presenter = MyFrPresenter.new
    @sections = Section.all

    render "layouts/footer"
  end

  def error_page
    render template: 'errors/500', layout: 'minimal'
  end
end
