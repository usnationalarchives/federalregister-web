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

  # note available_on cannot be used with other conditions
  # the api uses a non-sphinx based code path for this and
  # ignores all other conditions when this is present
  def self.available_on(date)
    {
      conditions: {
        available_on: iso(date)
      }
    }
  end
end
