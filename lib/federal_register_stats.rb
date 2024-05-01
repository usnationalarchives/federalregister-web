class FederalRegisterStats
  attr_reader :beginning_of_month,
    :beginning_of_year,
    :date,
    :end_of_month,
    :launch_date

  STATISTIC_TYPES = [
    "comment_post_success",
    "comment_opened"
  ]
  def self.populate_daily_redis_stats_to_disk(date=Date.current - 1.day)
    STATISTIC_TYPES.each do |statistic_type|
      key   = "#{statistic_type}:#{date.to_s(:iso)}"
      count = $redis.zrangebyscore(key, 0, 1000, with_scores: true).sum{|x| x.last}
      Statistic.find_or_create_by!(
        statistic_type: statistic_type,
        date:           date,
        count:          count
      )
    end
  end

  def self.populate_redis_from_database
    STATISTIC_TYPES.each do |statistic_type|
      Statistic.find_each do |statistic|
        key = "#{statistic_type}:#{statistic.date.to_s(:iso)}"
        $redis.set(key, statistic.count)
      end
    end
  end

  def self.populate_all_statistic_types
    #NOTE: This should be run BEFORE we've migrated to a hosted redis.  Should be deleted if past 2024-06-01
    STATISTIC_TYPES.each do |statistic_type|
      populate_statistics_table_from_redis(statistic_type)
    end
  end

  def self.populate_statistics_table_from_redis(statistic_type)
    #NOTE: This should be run BEFORE we've migrated to a hosted redis.  Should be deleted if past 2024-06-01
    date_keys = $redis.keys("#{statistic_type}:*")
    date_keys.each do |key|
      date = Date.parse(key.split(":").last)
      count = $redis.zrangebyscore(key, 0, 1000, with_scores: true).sum{|x| x.last}
      if count
        stat = Statistic.find_or_create_by(
          statistic_type: statistic_type,
          date: date
        )
        stat.update!(count: count)
      end
    end
  end

  def initialize(date, env='production')
    #site launched on this day - no stats make sense before this
    @launch_date = Date.parse('2010-07-26')

    @date = Date.parse(date)
    @beginning_of_year = @date.beginning_of_year
    @beginning_of_month = @date.beginning_of_month
    @end_of_month = @date.end_of_month
  end

  def generate
    puts "Total # of Subscriptions:  #{subscriptions(launch_date, end_of_month)}"
    puts "YTD # of Subscriptions:  #{subscriptions(beginning_of_year, end_of_month)}"
    puts "New Subscriptions in #{beginning_of_month.strftime('%B')}: #{subscriptions(beginning_of_month, end_of_month)}"

    puts "Total # of Comments in #{beginning_of_month.strftime('%B')} via Regulations.gov API integration:  #{comments_submitted}"
    puts "Total # of Comment Forms opened in #{beginning_of_month.strftime('%B')} on FederalRegister.gov:  #{comment_forms_opened}"
  end

  private

  def subscriptions(start_date = nil, end_date = nil)
    query = Subscription.where("unsubscribed_at IS NULL")

    if start_date
      query.where("created_at >= ? && created_at <= ?",start_date.to_s(:db), end_date.to_s(:db)).count
    else
      query.count
    end
  end

  def comments_submitted
    monthly_stat_count("comment_post_success")
  end

  def comment_forms_opened
    monthly_stat_count("comment_opened")
  end

  def monthly_stat_count(statistic_type)
    Statistic.
      where("MONTH(date) = ?", beginning_of_month).
      where("YEAR(date) = ?", beginning_of_year).
      where(statistic_type: statistic_type).
      sum(:count)
  end
end
