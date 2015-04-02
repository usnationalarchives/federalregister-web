class PublicInspectionDocumentIssue < FederalRegister::Facet::PublicInspectionIssue::Daily
  def self.current
    search(
      conditions: {
        publication_date: {
          gte: 1.month.ago.to_date.to_s(:iso)
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
end
