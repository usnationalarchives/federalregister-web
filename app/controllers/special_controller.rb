class SpecialController < ApplicationController
  skip_before_filter :authenticate_user!
  layout false, except: :home

  SECTIONS = {
    "money" => {
      title: "Money",
      id: 1,
    },
    "environment" => {
      title: "Environment",
      id: 2,
    },
    "world" => {
      title: "World",
      id: 3,
    },
    "science-and-technology" => {
      title: "Science and Technology",
      id: 4,
    },
    "business-and-industry" => {
      title: "Business and Industry",
      id: 5,
    },
    "health-and-public-welfare" => {
      title: "Health and Public Welfare",
      id: 6,
    },
  }

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
    @reader_aids_sections = ReaderAidsPresenter::Base.new.sections
    cache_for 1.day
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
  end

  def status
    current_time_on_database = Clipping.connection.select_values("SELECT NOW()").first
    render :text => "Current time is: #{current_time_on_database} (MyFR)"
  end

  def footer
    @reader_aids_sections = ReaderAidsPresenter::Base.new.sections
    @my_fr_presenter = MyFrPresenter.new
    # RW: Move to sections presenter after merge
    @sections = SECTIONS
    render "layouts/footer", layout: false
  end
end
