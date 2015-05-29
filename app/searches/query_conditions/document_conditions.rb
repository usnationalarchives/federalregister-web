class QueryConditions::DocumentConditions < QueryConditions
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
          gte: (DocumentIssue.current.publication_date - time_frame).to_s(:iso)
        }
      }
    }
  end

  def self.comments_opened_in_last(time_frame)
    {
      conditions: {
        publication_date: {
          gte: (DocumentIssue.current.publication_date - time_frame).to_s(:iso)
        },
        comment_date: {
          gte: Date.current.to_s(:iso),
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

  def self.published_on(date)
    {
      conditions: {
        publication_date: {is: date.to_s(:iso)},
      }
    }
  end

  def self.with_open_comment_periods_on(date)
    {
      conditions: {
        comment_date: {gte: date.to_s(:iso)},
        publication_date: {lte: date.to_s(:iso)}
      }
    }
  end
end
