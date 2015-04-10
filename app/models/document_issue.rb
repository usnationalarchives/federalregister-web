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

  def publication_date
    Date.parse(slug)
  end

  def self.published_on(date)
    DocumentIssue.search(QueryConditions.published_on(date.to_date)).results
  end

end
