class PublicInspectionDocumentIssue < FederalRegister::Facet::PublicInspectionIssue::Daily
  def self.current
    timespan = Rails.env.development? ? 1.year.ago : 1.month.ago

    search(
      conditions: {
        publication_date: {
          gte: timespan.to_date.to_s(:iso)
        }
      }
    ).last
  end

  def self.available_on(date)
    search(
      conditions: {
        publication_date: {
          gte: date.to_s(:iso),
          lte: date.to_s(:iso)
        }
      }
    ).last
  end

  def publication_date
    Date.parse(slug)
  end

  def has_documents?
    regular_filings.documents > 0 || special_filings.documents > 0
  end

  def self.available_for?(date)
    available_on(date)
  end

  def self.for_month(date)
    search(
      QueryConditions::DocumentConditions.published_within(
        date.beginning_of_month,
        date.end_of_month
      )
    )
  end

  def self.within(start_date, end_date)
    search(
      QueryConditions::DocumentConditions.published_within(
        Date.new(2019,1,1),
        end_date
      )
    )
  end
end
