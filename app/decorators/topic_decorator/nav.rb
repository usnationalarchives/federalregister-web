class TopicDecorator::Nav < TopicDecorator
  def comment_period_closing_count
    FederalRegister::Article.search_metadata(comment_period_closing_conditions).count
  end

  # RW: global nav conditions?  pass in type of id?
  def publication_date_conditions
    # RW: @issue.publication_date
    {
      :conditions => {
        :publication_date => {:gte => Date.current - 1.week},
        :topics => identifier
      }
    }
  end

  def comment_period_closing_conditions
    {
      :conditions => {
        :comment_date => {
          :gte => (Date.current).to_s(:year_month_day),
          :lte => 1.week.from_now.to_date.to_s(:year_month_day)
        },
        :topics => identifier
      }
    }
  end

  def entry_counts_since(range_type)
    date = case range_type
      when 'week'
        1.week.ago
      when 'month'
        1.month.ago
      when 'quarter'
        3.months.ago
      when 'year'
        1.year.ago
      end
    
    FederalRegister::Article.search_metadata(
      :conditions => {
        :topics => identifier,
        :publication_date => {
          :gte => date.to_s(:year_month_day)
        }
      }
    ).count
  end
end
