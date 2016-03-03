class DocumentIssuePresenter
  include RouteBuilder::Fr2ApiUrls

  attr_reader :date, :options

  def initialize(date, options={})
    @date = date.is_a?(Date) ? date : Date.parse(date)
    @options = options
  end

  def metadata_bar_name
    current_issue_page? ? "Current Issue" : date
  end

  def current_issue_page?
    options["toc_page"] != true
  end

  def entry_dates_for_month
    FederalRegister::Facet::Document::Daily.search(
      {:conditions =>
        {:publication_date =>
          {:gte => @date.beginning_of_month,
           :lte => @date.end_of_month
          }
        }
      }
    ).select{|result|result.count > 0}.map{|result|result.slug.to_date  }
  end

  def document_counts
   @document_counts ||= DocumentTypeFacet.
      search(
        conditions: {
          publication_date: {is: date}
        }
      )
  end

  def significant_documents
    @significant_documents ||= SignificantDocument.new(date)
  end

  def significant_documents?
    significant_documents.count > 0
  end

  class SignificantDocument
    vattr_initialize :date

    def name
      'Significant Document'
    end

    def count
      @count = documents.inject(0){|sum, d| sum += d.count; sum}
    end

    def search_conditions
      documents.conditions
    end

    def documents
      @documents_facets ||= DocumentTypeFacet.search(
        conditions: {
          significant: 1,
          publication_date: {is: date}
        }
      )
    end
  end

  def page_count
    return @page_count if @page_count

    sorted = documents.sort_by(&:start_page)
    if sorted.present?
      @page_count = sorted.last.end_page - sorted.first.start_page + 1 #inclusive
    else
      @page_count = 0
    end
  end

  # e.g. are we displaying this issue under the documents/current url?
  def current_issue?
    options && options[:current_issue]
  end

  def meta_page_title
    if current_issue?
      "Current Federal Register Document Issue"
    else
      "Federal Register Document Issue for #{date.to_formatted_s(:pretty)}"
    end
  end

  def meta_description
    description = "Notices, Proposed Rules, Rules, and Presidential Documents published in the "

    if current_issue?
      description + "current issue of the Federal Register."
    else
      description + "Federal Register on #{date.to_formatted_s(:pretty)}."
    end
  end

  def feed_urls
    feeds = []

    feeds << FeedAutoDiscovery.new(
      url: documents_search_api_url({}, format: :rss),
      description: Search::Document.new({}).summary,
      search_conditions: {}
    )

    feeds
  end

  private

  def documents
    @documents ||= Document.search(
      conditions: {
        publication_date: {is: date},
      },
      fields: [:end_page, :publication_date, :start_page],
    )
  end
end
