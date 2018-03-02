require 'resque-scheduler'
require 'resque/scheduler/server'

REDIS_CONNECTION_SETTINGS = {
  :db   => SECRETS['redis']['db'],
  :host => SECRETS['redis']['host'],
  :port => SECRETS['redis']['port']
}

$redis = Redis.new(REDIS_CONNECTION_SETTINGS)

HTTParty::HTTPCache.redis = $redis

Resque.redis = $redis
#Resque.schedule = YAML.load_file(File.join(Rails.root, 'config/resque_schedule.yml'))

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    # We're in smart spawning mode.
    if forked
      $redis.client.disconnect

      $redis = Redis.new(REDIS_CONNECTION_SETTINGS)
      HTTParty::HTTPCache.redis = $redis

      Resque.redis = $redis
      #Resque.schedule = YAML.load_file(File.join(Rails.root, 'config/resque_schedule.yml'))
    end
  end
end
