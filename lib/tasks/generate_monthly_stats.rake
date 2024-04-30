namespace :monthly do
  namespace :stats do
    task :generate, [:date] => :environment do |t, args|
      require 'federal_register_stats'

      stats = FederalRegisterStats.new(args[:date]).generate
    end

    task :persist_daily_redis_stats_to_disk do |t, args|
      stats = FederalRegisterStats.populate_daily_redis_stats_to_disk
    end
  end
end
