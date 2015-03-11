class DocumentIssue

  def self.current_date
    Date.parse(current.slug)
  end

  private
  # TODO: memoize me somehow, someway
  def self.current
    FederalRegister::Facet::Document::Daily.search(
      conditions: {
        publication_date: {
          gte: 1.month.ago.to_date.to_s(:iso)
        }
      }
    ).results.last
  end
end
