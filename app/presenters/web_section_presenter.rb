class WebSectionPresenter
  attr_reader :slug, :suggested_searches

SECTIONS = {
    "money" => {
      title: "Money",
      id: 1,
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

def initialize(slug)
  if all_sections[slug] == nil
    raise "Invalid slug.  Valid slugs are #{all_sections.keys}"
  else
    @slug = slug
  end
end

def section_title
  all_sections[slug][:title]
end

def suggested_searches
  @suggested_searches ||= FederalRegister::SuggestedSearch.search(conditions: {sections: [@slug]})[slug]
end

def all_sections
  SECTIONS
end

end