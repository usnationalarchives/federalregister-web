  class ExecutiveOrderNavPresenter
  attr_reader :current_president

  def initialize
    @current_president = presidents.last
  end

  def presidents
    President.all
  end

  def presidential_facet_collections
    presidents.map do |president|
      [president, EoCollectionFacet.new(president, :yearly)]
    end
  end
end
