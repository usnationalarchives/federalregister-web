class SpecialController < ApplicationController
  skip_before_action :authenticate_user!
  layout false, except: :home

  def user_utils
    if user_signed_in?
      @clipboard_clippings = Clipping.where(folder_id: nil, user_id: current_user.id).with_preloaded_documents || []
      @folders = FolderDecorator.decorate( Folder.where(creator_id: current_user.id).all )
    elsif cookies[:document_numbers].present?
      @clipboard_clippings = Clipping.all_preloaded_from_cookie( cookies[:document_numbers] ) || []
      @folders   = []
    else
      cache_for 1.day
      @clipboard_clippings = []
      @folders = []
    end
  end

  def home
    cache_for 1.day
  end

  def navigation
    cache_for 1.day
  end

  def header
    cache_for 1.day
    render template: "special/header/#{params[:type].gsub('-','_')}"
  end

  def robots
    cache_for 1.day
    render 'robots', layout: false, content_type: 'text/plain'
  end

  def status
    render plain: "Serving requests (MyFR)"
  end

  def site_notifications
    cache_for 1.day
    raw_response = HTTParty.get(
      "#{Settings.federal_register.internal_api_url}/site_notifications/#{params[:identifier]}"
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

  def popular_documents
    cache_for 1.hour

    @popular_documents = PopularDocument.popular.sort_by(&:comment_count).reverse.first(PopularDocument::POPULAR_DOCUMENT_COUNT)

    render 'special/home/popular_documents'
  end

  def error_page
    render template: 'errors/500', layout: 'minimal'
  end
end
