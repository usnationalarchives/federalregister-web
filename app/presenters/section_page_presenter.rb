class SectionPagePresenter
  attr_reader :date, :icon_name, :search_conditions,:slug, :suggested_searches
  class InvalidSection < StandardError; end

  def initialize(slug, date)
    raise InvalidSection unless all_section_slugs.include?(slug)
    @slug = slug
    @date = date.is_a?(Date) ? date : Date.parse(date)
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

  def icon_name
    SectionSlug.find_by_slug(slug).try(:icon)
  end

  def search_conditions
    {
      conditions:
      {
        sections: slug
      }
    }
  end

  def section_title
    SectionSlug.find_by_slug(slug).try(:title)
  end

  def suggested_searches
    @suggested_searches ||= SuggestedSearch.search(conditions: {sections: [@slug]})[slug]
  end

  def all_section_slugs
    SectionSlug.all.map(&:slug)
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
