class PresidentialDocumentCollection
  attr_reader :president, :year, :date_range, :document_types

  FIELDS = [
    :citation,
    :document_number,
    :end_page,
    :html_url,
    :pdf_url,
    :type,
    :subtype,
    :publication_date,
    :signing_date,
    :start_page,
    :title,
  ]

  EXECUTIVE_ORDER_FIELDS = FIELDS + [
    :disposition_notes,
    :executive_order_number,
  ]

  PRESIDENTIAL_DOCUMENT_FIELDS = FIELDS + [
    :disposition_notes,
  ]

  PROCLAMATION_FIELDS = FIELDS + [
    :disposition_notes,
    :proclamation_number,
  ]

  def initialize(president, document_types, year, date_range=nil)
    @president = president
    @year = year
    @document_types = document_types

    @date_range ||= @president.year_ranges[@year]
  end

  def results
    return @results if @results

    if document_types == 'executive_order'
      order = 'executive_order_number'
      fields = EXECUTIVE_ORDER_FIELDS
    elsif document_types == 'proclamation'
      order = 'proclamation_number'
      fields = PROCLAMATION_FIELDS
    else
      order = 'document_number'
      fields = PRESIDENTIAL_DOCUMENT_FIELDS
    end

    results = Document.search(
      QueryConditions::PresidentialDocumentConditions.presidential_documents(
        president, year, document_types
      ).deep_merge!({
        conditions: {correction: 0},
        fields: fields,
        order: order,
        per_page: '1000'
      })
    ).map do |document|
      DocumentDecorator.decorate(document)
    end.compact

    @results = %w(executive_order proclamation).include?(document_types) ? results.reverse : results
  end
  alias_method :presidential_documents, :results

  def count
    results.count
  end

  def minimum_eo_number
    results.last.executive_order_number
  end

  def maximum_eo_number
    results.first.executive_order_number
  end
end
