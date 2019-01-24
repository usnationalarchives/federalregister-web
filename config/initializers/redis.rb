# require 'resque-scheduler'
# require 'resque/scheduler/server'

REDIS_CONNECTION_SETTINGS = {
  :db   => Rails.application.secrets['redis']['db'],
  :host => Rails.application.secrets['redis']['host'],
  :port => Rails.application.secrets['redis']['port']
}

$redis = Redis.new(REDIS_CONNECTION_SETTINGS)

HTTParty::HTTPCache.redis = $redis

Resque.redis = $redis
#Resque.schedule = YAML.load_file(File.join(Rails.root, 'config/resque_schedule.yml'))
