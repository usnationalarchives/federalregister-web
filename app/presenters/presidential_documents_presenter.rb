class PresidentialDocumentsPresenter
  extend Memoist
  include RouteBuilder::Fr2ApiUrls
  attr_reader :h, :president, :presidential_document_type, :type, :year

  def initialize(args)
    @type = args[:type].gsub('-','_')
    @h = args[:view_context]
    @year = args[:year]

    @presidential_document_type = PresidentialDocumentType.find(@type.singularize)
    @president = lookup_president(args)
  end

  def name
    presidential_document_type.name.pluralize
  end

  def description
    I18n.t("presidential_documents.#{type}.description").html_safe
  end

  def display_disposition_notes?
    type == 'executive_orders' ||
    type == 'proclamations'
  end

  def table_description
    I18n.t("presidential_documents.#{type}.tables", president: President.first.full_name).html_safe
  end

  def link_to_presidential_documents_for_format(format)
    text = case format
           when :json
             "JSON"
           when :csv
             "CSV/Excel"
           end

    h.link_to text, h.documents_search_path(
      conditions_for_format(format)
    )
  end

  def feed_autodiscovery
    search_conditions = conditions_for_format(:json)

    FeedAutoDiscovery.new(
      url: documents_search_api_path(
        {conditions: search_conditions[:conditions]},
        format: :rss
      ),
      description: Search::Document.new(
        conditions: search_conditions[:conditions]
      ).summary,
      search_conditions: search_conditions[:conditions]
    )
  end

  def documents_by_president_and_year
    presidents.sort_by(&:starts_on).reverse.map do |president|
      presidential_years = president.
        year_ranges.
        map do |year_range|
          PresidentialDocumentCollection.new(
            president,
            presidential_document_type.identifier,
            year_range.first,
            year_range.second
          )
        end.
        sort_by(&:year).
        reverse
      [president, presidential_years]
    end
  end

  def presidential_documents_collection
    @presidential_documents_collection ||= PresidentialDocumentCollection.new(
      president, presidential_document_type.identifier, year
    )
  end

  def fr_content_box_type
    :reader_aid
  end

  def fr_content_box_title
    I18n.t("presidential_documents.#{type}.fr_box_title").html_safe
  end

  def fr_details_box_type
    :reader_aid_navigation
  end

  def fr_details_box_title
    I18n.t("presidential_documents.#{type}.fr_details_box_title").html_safe
  end

  def no_results?(president, year)
    eo_count_by_president_identifier_and_year["#{president.identifier}-#{year}"].nil?
  end

  def presidents
    if presidential_document_type.include_pre_1993_presidents
      President.all.reverse
    else
      President.all.select{|x| x.starts_on.year >= 1993}.reverse
    end
  end
  memoize :presidents

  private

  def lookup_president(args)
    if args[:president]
      if args[:president].is_a?(President)
        args[:president]
      else
        raise "A president object must be supplied.  A #{args[:president].class} was provided instead."
      end
    end
  end

  def eo_count_by_president_identifier_and_year
    # Possible Speed Optimization: Limit query by presidential dates to optimize speed
    presidents.each_with_object(Hash.new) do |president, hsh|
      EoCollectionFacet.new(president, :yearly).facet.each do |facet|
        if facet.count > 0
          key = "#{president.identifier}-#{facet.year}"
          hsh[key] = facet.count
        end
      end
    end
  end
  memoize :eo_count_by_president_identifier_and_year


  def conditions_for_format(format)
    if presidential_document_type.identifier == 'executive_order'
      order = 'executive_order'
      fields = PresidentialDocumentCollection::EXECUTIVE_ORDER_FIELDS
    elsif presidential_document_type.identifier == 'proclamation'
      order = 'proclamation_number'
      fields = PresidentialDocumentCollection::PROCLAMATION_FIELDS
    else
      order = 'document_number'
      fields = PresidentialDocumentCollection::PRESIDENTIAL_DOCUMENT_FIELDS
    end

    fields = case format
             when :json
               fields + %w(full_text_xml_url body_html_url json_url)
             when :csv
               fields
             end

    QueryConditions::PresidentialDocumentConditions.presidential_documents(
      president, year, presidential_document_type.identifier
    ).deep_merge!({
      conditions: {correction: 0},
      fields: fields,
      format: format,
      order: order,
      per_page: presidential_document_type.maximum_per_page || 1000,
      maximum_per_page: presidential_document_type.maximum_per_page || 1000,
      include_pre_1994_docs: true
    }).tap do |params|
      if president
        params.deep_merge!(
          conditions: {
            signing_date: {
              gte: president.starts_on,
              lte: (president.ends_on + 1.day) #To account for signings that occur on the morning of their last day in office
            },
          }
        )
      end
    end
  end
end
