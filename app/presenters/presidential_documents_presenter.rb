class PresidentialDocumentsPresenter
  attr_reader :h, :president, :presidential_document_type, :type, :year

  def initialize(args)
    @type = args[:type].gsub('-','_')
    @h = args[:view_context]
    @year = args[:year]

    @presidential_document_type = PresidentialDocumentType.find(@type.singularize)
    @president = President.find_by_identifier(args[:president])
  end

  def name
    presidential_document_type.name.pluralize
  end

  def description
    I18n.t("presidential_documents.#{type}.description").html_safe
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

  def documents_by_president_and_year
    President.all.sort_by(&:starts_on).reverse.map do |president|
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
    "#{presidential_document_type.name} Disposition Tables"
  end

  def fr_details_box_type
    :reader_aid_navigation
  end

  def fr_details_box_title
    "#{presidential_document_type.name} Disposition Tables"
  end

  private

  def conditions_for_format(format)
    if presidential_document_type.identifier == 'executive_order'
      order = 'executive_order'
      fields = PresidentialDocumentCollection::EXECUTIVE_ORDER_FIELDS
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
      per_page: '1000',
    })
  end
end
