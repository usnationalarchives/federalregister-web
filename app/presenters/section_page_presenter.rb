class SectionPagePresenter
  attr_reader :date, :search_conditions, :section
  class InvalidSection < StandardError; end

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
      description: "Significant Documents in #{section_title}",
      search_conditions: {sections: slug, significant: 1}
    )
    feeds << FeedAutoDiscovery.new(
      url: "/#{slug}.rss",
      public_inspection_search_possible: public_inspection_search_possible?,
      description: "All Documents in #{section_title}",
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

  def last_five_days_hash
    dates_array = (self.date - 4.days..self.date).to_a
    hsh={}
    dates_array.each {|date|
      hsh[date] = last_five_days.
        results.map{|document| DocumentDecorator.decorate(document)
      }
    }
    hsh
  end

  private
  def last_five_days
    @api_results ||= FederalRegister::Document.search(
      conditions: {
        sections: [slug],
        publication_date: {
          is: date.to_date
        }
      },
      order: 'newest',
      per_page: 40
    )
  end


end
