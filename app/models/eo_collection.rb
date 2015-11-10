class EoCollection
  attr_reader :president, :year, :date_range

  FIELDS = [
    :executive_order_number,
    :title, 
    :publication_date,
    :signing_date,
    :citation,
    :document_number,
    :executive_order_notes,
    :html_url
  ]

  def initialize(president, year, year_range=nil)
    @president = president
    @year = year
    @date_range ||= @president.year_ranges[@year]
  end

  def results
    @results ||= FederalRegister::Article.search(
      conditions: {
        president: president.identifier,
        presidential_document_type: 'executive_order',
        publication_date: {
          year: year
        }
      },
      fields: FIELDS + ['start_page','end_page'],
      order: 'executive_order_number',
      per_page: '200'
    ).map do |document|
      unless document.executive_order_number == 0
        DocumentDecorator.decorate(document) 
      end
    end.compact.reverse
  end
  alias_method :executive_orders, :results

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

