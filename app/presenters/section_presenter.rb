class SectionPresenter
  attr_reader :section_id, :documents, :slug, :section

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
    @section_id = get_section_id(slug)
    @slug = slug
    @documents = get_documents
  end

  def get_documents
    raw_documents = Document.search(
      conditions: {
        sections: [section_id]
      },
      order: 'newest',
      per_page: 40
    ).map{|doc| DocumentDecorator.decorate(doc)}
  end

  def section
    @section ||= Section.new(section_id, slug, documents)
  end

  class Section
    attr_reader :documents, :slug, :id, :documents_by_date, :title
    delegate :entries, to: :documents
    def initialize(section_id, slug, documents)
      @documents = documents
      @documents_by_date = {}
      @id = section_id
      @slug = slug
    end

    def title
      @title ||= slug.
        split("-").
        map!{|word| word == slug.split("-").first || word == slug.split("-").last ? word.capitalize : word}.
        join(" ")
    end

    def documents_for_date(date)
      documents_by_date[date.to_s(:year_month)]
    end
  end

  def previous_dates(count)
    dates = []
    date = Date.today
    while dates.count < count || date < Date.today.advance(days: -10)
      search = Document.search(
        order: 'newest',
        conditions: {
          publication_date: {
            is: date.to_s(:year_month)
          }
        }
      )
      if search.results.present?
        dates << date
        section.documents_by_date[date.to_s(:year_month)] = search.
          results.
          map do |result|
            DocumentDecorator.decorate(result)
          end
      end
      date = date.advance(days: -1)
    end
    dates
  end

  private

  def get_section_id(section)
    SECTIONS.fetch(section)[:id]
  end
end
