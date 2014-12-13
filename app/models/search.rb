class Search < FormObject
  attr_reader :params
  attr_accessor :result_set,
    :errors,
    :regulatory_plan_count,
    :validation_errors,
    :conditions

  SEARCH_CONDITIONS = [
    :type,
    :term,
    :docket_id,
    :agencies,
  ]

  DOCUMENT_SEARCH_CONDITIONS = [
    :publication_date,
    :effective_date,
    :comment_date,
    :small_entity_ids,
    :presidential_document_type_id,
    :president,
    :significant,
    :regulation_id_number,
    :cfr,
    :near,
    :topics,
    :sections,
    :correction
  ]

  def initialize(params)
    @params = params
    @errors = {}
    @validation_errors = {}
    @conditions = params[:conditions] || {}

    # Set Page
    @page = params[:page].to_i
    @page = 1 if @page < 1 || @page > 50
  end

  def search_details
    @search_details ||= SearchDetails.new(conditions)
  end

  def results
    begin
      @collection ||= WillPaginate::Collection.create(@page, 20) do |pager|
        @result_set = FederalRegister::Article.search(
          conditions: conditions,
          page: @page,
          order: order, 
          per_page: per_page
        )
        pager.replace(result_set.map{|doc| DocumentDecorator.decorate(doc)})
        pager.total_entries = entry_count unless pager.total_entries
        pager.custom_page_count = result_set.total_pages
      end
    rescue FederalRegister::Client::BadRequest => e
      add_errors(e)
    end
  end

  def per_page
    params[:per_page] || 20
  end

  def order
    params[:order] || "relevance"
  end

  def valid_conditions
    @valid_conditions ||= conditions.reject do |key, val|
      @errors[key] = "is not a valid field" unless respond_to?(key)
    end
  end

  def public_inspection_document_count
    FederalRegister::PublicInspectionDocument.search_metadata(
      conditions: valid_conditions.except(*DOCUMENT_SEARCH_CONDITIONS)
    ).count
  end

  def result_metadata
    begin
      @result_metadata ||= FederalRegister::Article.search_metadata(
        conditions: valid_conditions 
      )
    rescue FederalRegister::Client::BadRequest => e
      add_errors(e)
    end
  end

  def entry_count
    result_metadata.count
  end

  def summary
    if term.blank?
      "All Documents"
    else
      result_metadata.description
    end
  end

  def conditions_blank?
    params[:conditions].blank?
  end

  def valid?
    result_metadata
    errors.empty? && validation_errors.empty?
  end

  delegate :as_json, :to => :valid_conditions

  SEARCH_CONDITIONS.concat(DOCUMENT_SEARCH_CONDITIONS).each do |param|
    define_method(param) do
      conditions[param]
    end
  end

  def near
    OpenStruct.new(
      location: conditions[:near].try(:[], :location),
      within: (conditions[:near].try(:[], :within) || 25)
    )
  end

  def cfr
    OpenStruct.new(
      title: conditions[:cfr].try(:[], :title),
      part: conditions[:cfr].try(:[], :part),
    )
  end

  FACETS = [:agency, :topic, :section]

  FACETS.each do |facet|
    define_method("#{facet}_ids") do
      conditions[facet.to_s.pluralize].present? || conditions["#{facet}_ids"].present?
    end
  end

  private

  def add_errors(error)
    error.response["errors"].each do |key, message|
      @validation_errors[key] = message
    end
  end
end

