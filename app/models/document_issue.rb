class DocumentIssue < FederalRegister::Facet::Document::Daily

  def self.current
    search(
      conditions: {
        publication_date: {
          gte: 1.month.ago.to_date.to_s(:iso)
        }
      }
    ).results.last
  end

  def self.published_on(date)
    search(
      QueryConditions.published_on(date)
    ).results.first
  end

  def self.pdf_download_available?(date)
    date > Date.parse('1995-01-01')
  end

  def self.last_issue_published(year)
    facet = search(
      QueryConditions::DocumentConditions.published_within(
        Date.new(year,1,1), Date.new(year,12,31)
      )
    ).results.reverse.detect{|result_set| result_set.count > 0}

    facet.slug.to_date if facet
  end

  def publication_date
    Date.parse(slug)
  end

  def has_documents?
    count > 0
  end

  def self.current_issue_is_late?
    current.publication_date != Date.current &&
      (Time.current > Time.zone.parse("9AM")) &&
      should_have_an_issue?(Date.current)
  end

  def self.should_have_an_issue?(date)
    date <= Date.current &&
      ! (date.wday == 0 || date.wday == 6) &&
      ! Holiday.is_a_holiday?(date)
  end

  def self.for_month(date)
    search(
      QueryConditions::DocumentConditions.published_within(
        date.beginning_of_month,
        date.end_of_month
      )
    )
  end
end
