class SearchPresenter
  attr_accessor :params
  def initialize(params)
    @params = params
  end

  def conditions
    params["conditions"] || {}
  end

  def supported_orders
    %w(Relevant Newest Oldest)
  end

  def search
    @search ||= Search.new(params)
  end

  def agencies
    @agencies ||= FederalRegister::Agency.all
  end

  def agency_ids
    agencies.map(&:id)
  end
end
