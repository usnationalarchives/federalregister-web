class CommentStatAggregator
  require 'csv'

  attr_reader :date, :threshold, :type

  # date: "2018-01-01", "2018-01*"
  def initialize(date, type="comment_post_success", threshold=10.0)
    @date = date
    @type = type
    @threshold = threshold
  end

  def aggregate_by_ip
    @aggregate ||= counts_by_ip.reduce({}) do |sums, location|
      sums.merge(location) { |_, a, b| a + b }
    end
  end

  def keys
    @keys ||= $redis.keys("#{type}:#{date}")
  end

  def counts_by_ip
    @counts_by_ip ||= keys.map do |key|
      Hash[$redis.zrangebyscore(key, 0, 10000, with_scores: true)].select{|k,v| v >= threshold}
    end
  end

  def as_csv
    CSV.generate do |csv|
      aggregate_by_ip.to_a.each do |row|
        csv << row
      end
    end
  end
end
