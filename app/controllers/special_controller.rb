class SpecialController < ApplicationController
  skip_before_filter :authenticate_user!
  layout false, except: :home

  def user_utils
    if user_signed_in?
      @clipboard_clippings = Clipping.scoped(:conditions => {:folder_id => nil, :user_id => current_user.id}).with_preloaded_articles || []
      @folders = FolderDecorator.decorate( Folder.scoped(:conditions => {:creator_id => current_user.model}).all )
    elsif cookies[:document_numbers].present?
      @clipboard_clippings = Clipping.all_preloaded_from_cookie( cookies[:document_numbers] ) || []
      @folders   = []
    else
      cache_for 1.day
      @clipboard_clippings = []
      @folders = []
    end
  end

  def navigation
  end

  def shared_assets
    cache_for 1.day
  end

  def header
    cache_for 1.day
    render template: "special/header/#{params[:type].gsub('-','_')}"
  end

  def home
    cache_for 1.day
    @agencies_presenter = Facets::AgenciesPresenter.new
    @topics_presenter = Facets::TopicsPresenter.new
  end

  def fr2_assets
    cache_for 1.day
  end

  def my_fr_assets
    cache_for 1.day
  end

  def status
    current_time_on_database = Clipping.connection.select_values("SELECT NOW()").first
    render :text => "Current time is: #{current_time_on_database} (MyFR)"
  end

  def reader_aids
    render "special/home/reader_aids", layout: false
  end

  def site_notifications
    cache_for 1.minute
    raw_response = HTTParty.get(
      "#{FederalRegister::Base.base_uri}/site_notifications/#{params[:identifier]}"
    )
    if raw_response.code == 404
      render :nothing => true
    else
      @response = raw_response.parsed_response
    end
  end

  def footer
    cache_for 1.day

    @reader_aids_sections = ReaderAidsPresenter::Base.new.sections
    @my_fr_presenter = MyFrPresenter.new
    @sections = SectionPresenter::SECTIONS

    render "layouts/footer", layout: false
  end
end
