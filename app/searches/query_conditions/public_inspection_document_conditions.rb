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
end
