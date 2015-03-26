class SectionPagePresenter
  attr_reader :slug, :date, :suggested_searches

  SECTIONS = {
      "money" => {
        title: "Money",
        id: 1,
        icon: "icon-fr2-Coins-dollaralt"
      },
      "environment" => {
        title: "Environment",
        id: 2,
      },
      "world" => {
        title: "World",
        id: 3,
      },
      "science-and-technology" => {
        title: "Science and Technology",
        id: 4,
      },
      "business-and-industry" => {
        title: "Business and Industry",
        id: 5,
      },
      "health-and-public-welfare" => {
        title: "Health and Public Welfare",
        id: 6,
      },
    }

  def initialize(slug, date)
    if all_sections[slug] == nil
      raise "Invalid slug.  Valid slugs are #{all_sections.keys}"
    else
      @slug = slug
      @date = date
    end
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

  def self.all_section_slugs
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