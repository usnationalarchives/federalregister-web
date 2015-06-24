class QueryConditions::DocumentConditions < QueryConditions
  def self.comment_period_closing_in(time_frame)
    {
      conditions: {
        comment_date: {
          gte: iso(Date.current),
          lte: iso(time_frame.from_now.to_date)
        }
      }
    }
  end

  def self.published_in_last(time_frame)
    {
      conditions: {
        publication_date: {
          gte: iso(DocumentIssue.current.publication_date - time_frame)
        }
      }
    }
  end

  def self.comments_opened_in_last(time_frame)
    {
      conditions: {
        publication_date: {
          gte: iso(DocumentIssue.current.publication_date - time_frame)
        },
        comment_date: {
          gte: iso(Date.current),
        }
      }
    }
  end

  def self.published_within(start_date, end_date)
    {
      conditions: {
        publication_date: {
          gte: iso(start_date),
          lte: iso(end_date)
        }
      }
    }
  end

  def self.published_on(date)
    {
      conditions: {
        publication_date: {is: iso(date)},
      }
    }
  end

  def self.with_open_comment_periods_on(date)
    {
      conditions: {
        comment_date: {gte: iso(date)},
        publication_date: {lte: iso(date)}
      }
    }
  end

  def self.published_since(date)
    published_within(date, DocumentIssue.current.publication_date)
  end
end
