class PublicInspectionIssuePresenter
  include RouteBuilder::Fr2ApiUrls

  attr_reader :agencies, :date, :options, :regular_filings, :special_filings

  def initialize(date, options={})
    @date = date.is_a?(Date) ? date : Date.parse(date)
    @options = options
    @regular_filings = RegularFilings.new(@date, self)
    @special_filings = SpecialFilings.new(@date, self)
    @agencies = {}
  end

  def all_filings
    [@special_filings, @regular_filings]
  end

  def issue
    @issue ||= PublicInspectionDocumentIssue.available_on(date)
  end

  # e.g. are we displaying this issue under the documents/current url?
  def current_issue?
    options && options[:current_issue]
  end

  def meta_page_title
    if current_issue?
      "Federal Register Documents Currently on Public Inspection"
    else
      "Federal Register Documents on Public Inspection for #{date.to_formatted_s(:pretty)}"
    end
  end

  def meta_description
    description = "The following are a preview of unpublished Federal Register documents "

    if current_issue?
      description + "currenly on Public Inspection and scheduled to be published on the dates listed."
    else
      description + "on Public Inspection for #{date.to_formatted_s(:pretty)} and scheduled to be published on the dates listed."
    end
  end

  def feed_urls
    feeds = []

    feeds << FeedAutoDiscovery.new(
      url: public_inspection_search_api_url({}, format: :rss),
      description: Search::PublicInspection.new({}).summary,
      search_conditions: {}
    )

    feeds
  end

  class BasicFilings
    extend Memoist
    attr_reader :publication_date, :public_inspection_issue
    def initialize(date, presenter)
      @publication_date = date
      @public_inspection_issue = presenter.issue
    end

    def formatted_updated_at
      filings.last_updated_at.try(:to_s, :time_then_date)
    end

    def agency_count
      filings.agencies
    end

    def document_count
      filings.documents
    end

    def type
      @type ||= name.downcase.gsub(' ', '-')
    end

    def filing_facets
      @filing_facets ||= PublicInspectionIssueTypeFacet.search(
        QueryConditions::PublicInspectionDocumentConditions.
          published_on(publication_date)
      ).first
    end


    def special_filing?
      type == 'special-filing'
    end

    def display_links?
      # pil isn't technically current on Saturdays as documents have published as part of the import of
      # Monday's issue but we don't yet have an updated pil
      pil_current = public_inspection_issue.publication_date >= DocumentIssue.current.publication_date

      pil_current = true if Rails.env.development?

      (document_count != 0) && pil_current
    end
    memoize :display_links?
  end

  class RegularFilings < BasicFilings
    def name
      "Regular Filing"
    end

    def search_conditions
      QueryConditions::PublicInspectionDocumentConditions.regular_filing
    end

    def filings
      public_inspection_issue.regular_filings
    end

    def document_type_facets
      filing_facets.regular_filings.document_types
    end
  end

  class SpecialFilings < BasicFilings
    def name
      "Special Filing"
    end

    def search_conditions
      QueryConditions::PublicInspectionDocumentConditions.special_filing
    end

    def filings
      public_inspection_issue.special_filings
    end

    def document_type_facets
      filing_facets.special_filings.document_types
    end
  end
end
