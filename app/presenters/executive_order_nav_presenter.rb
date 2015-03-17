class ExecutiveOrderNavPresenter
  attr_reader :current_president, :current_year, :presidents_and_years

  def initialize
    @presidents_and_years = self.class.all_by_president_and_year
    @current_president = @presidents_and_years.first.first
    @current_year = @presidents_and_years.first[1].first.year
  end

  def self.all_by_president_and_year
    @presidents_and_years_results ||= President.all.reverse.map do |president|
      presidential_years = president.year_ranges.map{|year_range| EoCollection.new(president, year_range.first, year_range.second)}.sort_by(&:year).reverse
      [president, presidential_years]
    end
  end

  def recent_executive_orders
    FederalRegister::Document.search(
      conditions: {
        president: current_president.identifier,
        presidential_document_type: 'executive_order',
        correction: 0,
        publication_date: {
          year: current_year
        }
      },
      fields: [
        'executive_order_number',
        'title',
        'html_url',
      ],
      order: 'executive_order_number',
      per_page: '1'
    ).first(3).map {|executive_order|
        ExecutiveOrder.new(
          executive_order_number: executive_order.executive_order_number,
          title: executive_order.title,
          html_url: executive_order.html_url
        )
      }
  end

  class ExecutiveOrder
    vattr_initialize [
      :executive_order_number,
      :title,
      :html_url
    ]
  end

  class EoCollection
    attr_reader :president, :year, :date_range

    def initialize(president, year, date_range=nil)
      @president = president
      @year = year
      @date_range ||= @president.year_ranges[@year]
    end

    def executive_orders
      facet_search
    end

    def search_conditions
      facet_search.conditions
    end

    def count
      facet_search.first.count if executive_orders.first
    end

    private
    def facet_search
      @facet_results ||= FederalRegister::Facet::Document::Yearly.search(conditions: {
        president: @president.identifier,
        presidential_document_type: 'executive_order',
        correction: 0,
        publication_date: {
          year: @year
        }
      },
      order: 'executive_order_number'
      )
    end

  end

end