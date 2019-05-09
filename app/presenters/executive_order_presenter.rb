class ExecutiveOrderPresenter
  attr_reader :president, :year, :h

  def initialize(options={})
    @president = President.find_by_identifier(options[:president])
    @year = options[:year]
    @h = options[:view_context]
  end

  def link_to_executive_orders_for_format(format, president_identifier=nil)
    text = case format
           when :json
             "JSON"
           when :csv
             "CSV/Excel"
           end

    h.link_to text, h.documents_search_path(
      conditions_for_format(format, president_identifier)
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

  def description
    "The President of the United States manages the operations of the Executive branch of Government through Executive orders. After the President signs an Executive order, the White House sends it to the Office of the Federal Register (OFR).
    The OFR numbers each order consecutively as part of a series and publishes it in the daily Federal Register shortly after receipt. For a table of Executive orders that are specific to federal agency rulemaking, see https://www.acus.gov/research-projects/tables-executive-order-requirements."
  end

  def agency
    Agency.find('executive-office-of-the-president')
  end

  def name
    'Executive Orders'
  end

  def fr_content_box_type
    :reader_aid
  end

  def fr_content_box_title
    "Executive Order Disposition Tables"
  end

  def fr_details_box_type
    :reader_aid_navigation
  end

  def fr_details_box_title
    "Executive Order Disposition Tables"
  end

  private

  def conditions_for_format(format, president_identifier=nil)
    fields = case format
             when :json
               EoCollection::FIELDS + %w(full_text_xml_url body_html_url json_url)
             when :csv
               EoCollection::FIELDS
             end

    {
      conditions: {
        type: ["PRESDOCU"],
        presidential_document_type_id: 2,
        correction: 0,
        president: president_identifier
      },
      :fields => fields,
      :per_page => 1000,
      :format => format,
      :order => "executive_order_number"
    }
  end
end
