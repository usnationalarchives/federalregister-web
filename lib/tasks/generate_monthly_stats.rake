namespace :monthly do
  namespace :stats do
    task :generate, [:date] do |t, args|
      require 'lib/federal_register_stats'

      stats = FederalRegisterStats.new(args[:date]).generate
    end
  end
end
