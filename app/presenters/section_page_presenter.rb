class SectionPagePresenter
  attr_reader :date, :icon_name, :search_conditions,:slug, :suggested_searches
  class InvalidSection < StandardError; end

  #TODO: Refactor the SECTIONS constant so we're using the API in lieu of hardcoding.
  SECTIONS = {
      "money" => {
        title: "Money",
        icon: "Coins-dollaralt"
      },
      "environment" => {
        title: "Environment",
        icon: "Eco"
      },
      "world" => {
        title: "World",
        icon: "Globe"
      },
      "science-and-technology" => {
        title: "Science and Technology",
        icon: "Lab"
      },
      "business-and-industry" => {
        title: "Business and Industry",
        icon: "Factory"
      },
      "health-and-public-welfare" => {
        title: "Health and Public Welfare",
        icon: "Medicine"
      },
    }

  def initialize(slug, date)
    raise InvalidSection unless all_section_slugs.include?(slug)
    @slug = slug
    @date = date
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
    all_sections[slug][:icon]
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
    all_sections[slug][:title]
  end

  def suggested_searches
    @suggested_searches ||= SuggestedSearch.search(conditions: {sections: [@slug]})[slug]
  end

  def all_sections
    SECTIONS
  end

  def all_section_slugs
    all_sections.keys
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