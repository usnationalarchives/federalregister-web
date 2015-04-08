class QueryConditions
  def self.published_on(date)
    {
      conditions: {
        publication_date: {
          is: date.to_s(:iso)
        }
      }
    }
  end
end
