class QueryConditions::PublicInspectionDocumentConditions < QueryConditions
  def self.regular_filing
    {
      conditions: {
        special_filing: 0
      }
    }
  end

  def self.special_filing
    {
      conditions: {
        special_filing: 1
      }
    }
  end

  def self.special_filings_available_on(date)
    special_filing.deep_merge({
      conditions: {available_on: iso(date)}
    })
  end

  def self.regular_filings_available_on(date)
    regular_filing.deep_merge({
      conditions: {available_on: iso(date)}
    })
  end
end
