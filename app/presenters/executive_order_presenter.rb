class ExecutiveOrderPresenter
  attr_reader :president, :year, :h

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

  def initialize(options={})
    @president = President.find_by_identifier(options[:president])
    @year = options[:year]
    @h = options[:view_context]
  end

  def link_to_executive_orders_for_format(format, president_identifier=nil)
    case format
    when :csv
      text = "CSV/Excel"
      fields = FIELDS
    when :json
      text = "JSON"
      fields = FIELDS + %w(full_text_xml_url body_html_url json_url)
    end

    h.link_to text, h.documents_search_path(
      :conditions => {
        :type => "PRESDOCU",
        :presidential_document_type_id => 2,
        :correction => 0,
        :president => president_identifier
      },
      :fields => fields,
      :per_page => 1000,
      :format => format,
      :order => "executive_order_number"
    )
  end

  def orders_by_president_and_year
    President.all.sort_by(&:starts_on).reverse.map do |president|
      presidential_years = president.
        year_ranges.
        map{|year_range| EoCollection.new(president, year_range.first, year_range.second)}.
        sort_by(&:year).
        reverse
      [president, presidential_years]
    end
  end

  def eo_collection
    @eo_collection ||= EoCollection.new(president, year)
  end

  class EoCollection
    attr_reader :president, :year, :date_range
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
end
