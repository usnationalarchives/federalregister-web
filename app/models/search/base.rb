class Search::Base
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  include ConditionsHelper

  SEARCH_CONDITIONS = [
    :agencies,
    :agency_ids,
    :docket_id,
    :term,
    :type,
  ]

  def initialize(params)
    @params = params
    @errors = {}
    @validation_errors = {}
    @conditions = clean_conditions(params[:conditions]) || {}

    # Set Page
    @page = params[:page].to_i
    @page = 1 if @page < 1 || @page > 50
  end

  def results
    begin
      @collection ||= WillPaginate::Collection.create(@page, 20) do |pager|
        @result_set = search_type.search(
          conditions: conditions,
          fields: search_type.search_fields,
          page: @page,
          order: order,
          per_page: per_page
        )
        pager.replace(DocumentDecorator.decorate_collection(result_set))
        pager.total_entries = result_count unless pager.total_entries
        pager.custom_page_count = result_set.total_pages
      end
    rescue FederalRegister::Client::BadRequest => e
      add_errors(e)
    end
  end

  def persisted?
    false
  end

  def search_details
    @search_details ||= SearchDetails.new(conditions)
  end

  def per_page
    params[:per_page] || 20
  end

  def order
    conditions[:order] || "relevance"
  end

  def valid_conditions
    @valid_conditions ||= conditions.select do |key, val|
      @errors[key] = "is not a valid field" unless respond_to?(key)
      respond_to?(key)
    end
  end

  def invalid_conditions
    conditions.reject do |key, val|
      respond_to?(key)
    end
  end

  def valid_search?
    invalid_conditions.empty?
  end

  def result_metadata
    begin
      @result_metadata ||= search_type.search_metadata(
        conditions: valid_conditions
      )
    rescue FederalRegister::Client::BadRequest => e
      add_errors(e)
    end
  end

  def result_count
    result_metadata.count
  end

  def summary
    result_metadata.description
  end

  def conditions_blank?
    conditions.blank?
  end

  def valid?
    result_metadata
    errors.empty? && validation_errors.empty?
  end

  delegate :as_json, :to => :valid_conditions

  def near
    OpenStruct.new(
      location: conditions[:near].try(:[], :location),
      within: (conditions[:near].try(:[], :within))
    )
  end

  def cfr
    OpenStruct.new(
      title: conditions[:cfr].try(:[], :title),
      part: conditions[:cfr].try(:[], :part),
    )
  end

  private

  def add_errors(error)
    error.response["errors"].each do |key, message|
      @validation_errors[key] = message
    end
  end
end
