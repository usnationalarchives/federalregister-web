class SectionPagePresenter
  attr_reader :date, :icon_name, :slug, :suggested_searches
  class InvalidSection < StandardError; end

  SECTIONS = {
      "money" => {
        title: "Money",
        id: 1,
        icon: "Coins-dollaralt"
      },
      "environment" => {
        title: "Environment",
        id: 2,
        icon: "Eco"
      },
      "world" => {
        title: "World",
        id: 3,
        icon: "Globe"
      },
      "science-and-technology" => {
        title: "Science and Technology",
        id: 4,
        icon: "Lab"
      },
      "business-and-industry" => {
        title: "Business and Industry",
        id: 5,
        icon: "Factory"
      },
      "health-and-public-welfare" => {
        title: "Health and Public Welfare",
        id: 6,
        icon: "Medicine"
      },
    }
  def initialize(slug, date)
    raise InvalidSection unless all_section_slugs.include?(slug)
    @slug = slug
    @date = date
  end

  def icon_name
    all_sections[slug][:icon]
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
      hsh[date] = FederalRegister::Document.search(
        conditions: {
          sections: [slug],
          publication_date: {
            is: date.to_date
          }
        },
        order: 'newest',
        per_page: 40).
        results.map{|document| DocumentDecorator.decorate(document)
      }
    }
    hsh
  end


end