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
          gte: (DocumentIssue.current_date - time_frame).to_s(:iso)
        }
      }
    }
  end

  def self.comments_opened_in_last(time_frame)
    {
      conditions: {
        publication_date: {
          gte: (DocumentIssue.current_date - time_frame).to_s(:iso)
        },
        comment_date: {
          gte: Date.current.to_s(:iso),
        }
      }
    }
  end
end
