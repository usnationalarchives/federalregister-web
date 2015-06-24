class AgencyPresenter
  attr_reader :agency

  delegate :agency_url,
    :name,
    :search_conditions,
    :slug,
    :total_document_count,
    :total_public_inspection_document_count,
    :total_significant_document_count,
    :url, to: :@agency

  def initialize(slug)
    @agency = Agency.find(slug)
  end

  def weekly_sparkline
    SparklinePresenter.new(
      QueryConditions::DocumentConditions.
        published_in_last(1.year).
        deep_merge!(search_conditions),
      period: :weekly,
      title: 'Last year, weekly'
    )
  end

  def monthly_sparkline
    SparklinePresenter.new(
      QueryConditions::DocumentConditions.
        published_in_last(5.years).
        deep_merge!(search_conditions),
      period: :monthly,
      title: 'Last 5 years, monthly'
    )
  end

  def quarterly_sparkline
    SparklinePresenter.new(
      QueryConditions::DocumentConditions.
        published_within('1994-01-01', DocumentIssue.current.publication_date).
        deep_merge!(search_conditions),
      period: :quarterly,
      title: 'Since 1994, quarterly'
    )
  end

  def document_results
    OpenStruct.new(
      documents: agency.documents(per_page: 10),
      per_page: 10,
      search_conditions: agency.search_conditions,
      total_document_count: agency.total_document_count
    )
  end

  def public_inspection_document_results
    OpenStruct.new(
      documents: agency.public_inspection_documents(per_page: 10),
      per_page: 10,
      search_conditions: agency.search_conditions,
      total_document_count: agency.total_public_inspection_document_count
    )
  end

  def significant_document_results
    OpenStruct.new(
      documents: agency.significant_documents(per_page: 5),
      per_page: 5,
      search_conditions: agency.search_conditions.deep_merge!(
        conditions: {significant: 1}
      ),
      total_document_count: agency.total_significant_document_count
    )
  end
end
