class SearchPresenter::Base
  attr_accessor :params
  def initialize(params)
    @params = params.symbolize_keys.except(:controller, :action)
  end

  def supported_orders
    %w(Relevant Newest Oldest)
  end

  def agencies
    @agencies ||= FederalRegister::Agency.all
  end

  def agency_ids
    agencies.map(&:id)
  end

  def display_suggestions?
    (search.params[:page].blank? || search.params[:page] == '1') &&
      search.params[:order].blank?
  end

  def search_suggestions
    search_details = search.search_details

    return nil unless search_details.present? &&
      search_details.suggestions.present?

    SearchPresenter::Suggestions.new(search_details.suggestions)
  end
end
