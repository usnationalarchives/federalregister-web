require 'spec_helper'

describe FederalRegisterStats do
  before(:each) do
    $redis = MockRedis.new
  end

  it "populate_redis_from_database" do
    date = Date.new(2024,3,1)
    Statistic.create!(date: date, count: 99, statistic_type: "comment_post_success")
    FederalRegisterStats.populate_redis_from_database
    expect($redis.get("comment_post_success:#{date.to_s(:iso)}")).to eq("99")
  end

  it "#populate_daily_redis_stats_to_disk" do
    if Settings.feature_flags.store_commenting_metadata_without_ip
      pending("")
    end
    $redis.zincrby "comment_post_success:#{Date.new(2024,3,5).to_s(:iso)}", 1, '44.242.75.21'
    $redis.zincrby "comment_post_success:#{Date.new(2024,3,5).to_s(:iso)}", 1, '44.242.75.21'
    $redis.zincrby "comment_post_success:#{Date.new(2024,3,5).to_s(:iso)}", 1, '44.242.75.25'

    described_class.populate_daily_redis_stats_to_disk(Date.new(2024,3,5))
    described_class.populate_daily_redis_stats_to_disk(Date.new(2024,3,5)) #test idempotence

    expect(Statistic.count).to eq(2)
    expect(Statistic.find_by!(statistic_type: "comment_post_success")).to have_attributes(
      statistic_type: "comment_post_success",
      date: Date.new(2024,3,5),
      count: 3
    )
  end

  it "#populate_all_statistic_types archives historical redis counts to the statistics table" do
    $redis.zincrby "comment_post_success:#{Date.new(2024,3,5).to_s(:iso)}", 1, '44.242.75.21'
    $redis.zincrby "comment_post_success:#{Date.new(2024,3,5).to_s(:iso)}", 1, '44.242.75.21'
    $redis.zincrby "comment_post_success:#{Date.new(2024,3,5).to_s(:iso)}", 1, '44.242.75.99'
    $redis.zincrby "comment_post_success:#{Date.new(2024,3,7).to_s(:iso)}", 1, '44.242.75.99'

    expected_attributes = [
      {statistic_type: 'comment_post_success', date: Date.new(2024,3,5), count: 3},
      {statistic_type: 'comment_post_success', date: Date.new(2024,3,7), count: 1}
    ].map(&:stringify_keys)

    described_class.populate_all_statistic_types
    described_class.populate_all_statistic_types #test idempotence

    results = Statistic.order(:date)
    results.each_with_index do |result, i|
      expect(result).to have_attributes(expected_attributes[i])
    end
  end

end
