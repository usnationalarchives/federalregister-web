class SearchController < ApplicationController
  include ConditionsHelper

  def header
    @presenter = SearchPresenter.new(params)
    @search = @presenter.search
    render :layout => false
  end

  def results
    @presenter = SearchPresenter.new(params)
    @search = @presenter.search
    @search_details = @search.search_details
    #cache_for 1.day
    respond_to do |wants|
      wants.html do
        render :layout => false
      end
      wants.js do
        if @search.valid?
          render :json => {:count => @search.entry_count, :message => render_to_string(:partial => "result_summary.txt.erb")}
        else
          render :json => {:errors => @search.validation_errors, :message => "Invalid parameters"}
        end
      end
    end
  end
end
