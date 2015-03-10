class Facets::QueryConditions
  def self.comment_period_closing_in(time_frame)
    {
      conditions: {
        comment_date: {
          gte: Date.current.to_s(:iso),
          lte: time_frame.from_now.to_date.to_s(:iso)
        }
      }
    }
  end

  def self.published_in_last(time_frame)
    {
      conditions: {
        publication_date: {
          gte: time_frame.ago.to_date.to_s(:iso)
        }
      }
    }
  end

  def self.published_within(start_date, end_date)
    {
      conditions: {
        publication_date: {
          gte: start_date.to_s(:iso),
          lte: end_date.to_s(:iso)
        }
      }
    }
  end
end