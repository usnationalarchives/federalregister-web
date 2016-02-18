class SectionPagePresenter
  include RouteBuilder::Documents
  
  attr_reader :date, :search_conditions, :section

  delegate :icon, :slug, :suggested_searches, :title, to: :@section

  def initialize(section, date)
    @section = section
    @date = date
  end

  def new_documents
    @new_documents ||= section.new_documents_for(date)
  end

  def new_document_conditions
    section.new_documents_for_date_conditions(date)
  end

  def open_comment_periods
    @open_documents ||= section.documents_with_open_comment_periods_for(date)
  end

  def open_comment_period_conditions
    section.documents_with_open_comment_periods_for_date_conditions(date)
  end

  def highlighted_documents
    section.highlighted_documents_for(date)
  end

  def feed_urls
    feeds = []

    feeds << FeedAutoDiscovery.new(
      url: documents_search_api_path(search_conditions, format: :rss),
      description: Search::Document.new(search_conditions).summary,
      search_conditions: search_conditions[:conditions]
    )

    feeds << FeedAutoDiscovery.new(
      url: documents_search_api_path(
        {conditions: search_conditions[:conditions].merge(significant: '1')},
        format: :rss
      ),
      description: Search::Document.new(
        conditions: search_conditions[:conditions].merge(significant: '1')
      ).summary,
      search_conditions: search_conditions[:conditions].merge(significant: '1')
    )

    feeds
  end

  def search_conditions
    {
      conditions:
      {
        sections: slug
      }
    }
  end

  def documents_in_last_five_issues
    @documents_from_last_five_days ||= Document.search(
    QueryConditions::DocumentConditions.
      published_within(
        last_five_issues_with_doc_counts.last,
        last_five_issues_with_doc_counts.first
      ).deep_merge!(
        conditions: {
          sections: [slug]
        },
        per_page: 1000
      )
    ).
      map{|document| DocumentDecorator.decorate(document)}.
      group_by{|doc| doc.publication_date}
  end

  def last_five_issues_with_doc_counts
    @last_five_dates_with_doc_counts ||= DocumentIssue.search(
      QueryConditions::DocumentConditions.
        published_within(date - 10.days, date)
    ).
      select{|facet| facet.count > 0}.
      map{|facet| facet.slug}.
      reverse.first(5)
  end
end
