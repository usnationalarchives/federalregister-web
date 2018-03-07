namespace :monthly do
  namespace :stats do
    task :generate, [:date] => :environment do |t, args|
      require 'federal_register_stats'

      stats = FederalRegisterStats.new(args[:date]).generate
    end
  end
end
