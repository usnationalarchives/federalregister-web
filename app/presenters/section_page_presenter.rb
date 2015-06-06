class SectionPagePresenter
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

  def public_inspection_search_possible?
    begin
      FederalRegister::PublicInspectionDocument.search_metadata(search_conditions)
      true
    rescue FederalRegister::Client::BadRequest
      false
    end
  end

  def feed_urls
    feeds = []
    feeds << FeedAutoDiscovery.new(
      url: "/#{slug}/significant.rss",
      public_inspection_search_possible: public_inspection_search_possible?,
      description: "Significant Documents in #{section.title}",
      search_conditions: {sections: slug, significant: 1}
    )
    feeds << FeedAutoDiscovery.new(
      url: "/#{slug}.rss",
      public_inspection_search_possible: public_inspection_search_possible?,
      description: "All Documents in #{section.title}",
      search_conditions: {sections: slug}
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

  def last_five_days_docs
    @documents_from_last_five_days ||= FederalRegister::Document.search(
      conditions: {
        sections: [slug],
        publication_date: {
          gte: last_five_dates_with_doc_counts.last,
          lte: last_five_dates_with_doc_counts.first
        }
      },
      per_page: 1000
    ).map{|document| DocumentDecorator.decorate(document)}.
        group_by{|doc|doc.publication_date.to_s(:iso)}
  end


  private

  def last_five_dates_with_doc_counts
    @last_five_dates_with_doc_counts ||= DocumentIssue.search(
      {:conditions =>
        {:publication_date =>
          {:gte => (date - 10.days).to_s(:iso),
           :lte => date.to_s(:iso)
          }
        }
      }
    ).select{|facet| facet.count > 0}.map{|facet| facet.slug}.
    reverse.first(5)
  end
end
