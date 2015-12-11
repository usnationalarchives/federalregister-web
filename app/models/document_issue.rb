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
    DocumentIssue.search(QueryConditions.published_on(date.to_date)).results.first
  end

  def self.pdf_download_available?(date)
    date > Date.parse('1995-01-01')
  end

  def publication_date
    Date.parse(slug)
  end

  def has_documents?
    count > 0
  end

  def self.current_issue_is_late?
    current.publication_date == Date.today &&
    (Time.current > Time.zone.parse("9AM")) &&
    should_have_an_issue?(Date.today)
  end

  def self.should_have_an_issue?(date)
    !(date.wday == 0 || date.wday == 6) #|| Holiday.find_by_date(date))
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
