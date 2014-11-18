class ExecutiveOrderPresenter
  attr_reader :president, :year, :eo_collection
  def initialize(options={})
    @president = President.new(options.fetch(:president))
    @year = options.fetch(:year)
  end

  def eo_collection
    @eo_collection ||= EoCollection.new(president, year)
  end

  class EoCollection
    attr_reader :results, :president, :year
    alias_method :executive_orders, :results
    def initialize(president, year)
      @president = president
      @year = year
      @results = fetch_collection
    end

    def fetch_collection
      FederalRegister::Article.search(
        conditions: {
          president: president.identifier,
          presidential_document_type: 'executive_order',
          publication_date: {
            year: year
          }
        },
        fields: [
          'executive_order_number',
          'publication_date',
          'title',
          'html_url',
          'document_number',
          'signing_date',
          'citation',
          'start_page',
          'end_page'
        ],
        order: 'executive_order_number',
        per_page: '200'
      ).map{|document| DocumentDecorator.decorate(document)}.reverse
    end

    def count
      results.count
    end

    def minimum_number
      results.last.executive_order_number
    end

    def maximum_number
      results.first.executive_order_number
    end
  end

  class President
    attr_reader :identifier
    def initialize(identifier)
      @identifier = identifier
    end

    def full_name
      identifier.split("-").map(&:capitalize).join(" ")
    end
  end
end
