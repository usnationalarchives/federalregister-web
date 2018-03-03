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
