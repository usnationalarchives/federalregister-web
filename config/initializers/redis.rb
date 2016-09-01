REDIS_CONFIG = YAML.load_file(Rails.root + 'config/redis.yml')[Rails.env].freeze

REDIS_CONNECTION_SETTINGS = {
  :db   => REDIS_CONFIG['db'],
  :host => REDIS_CONFIG['host'],
  :port => REDIS_CONFIG['port']
}

redis = Redis.new(REDIS_CONNECTION_SETTINGS)

$redis = Redis::Namespace.new(
  REDIS_CONFIG['namespace'],
  :redis => redis
)
HTTParty::HTTPCache.redis = $redis

Resque.redis = Redis.new(REDIS_CONNECTION_SETTINGS)

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    # We're in smart spawning mode.
    if forked
      $redis.client.disconnect
      $redis = Redis::Namespace.new(
        REDIS_CONFIG['namespace'],
        :redis => Redis.new(REDIS_CONNECTION_SETTINGS)
      )

      HTTParty::HTTPCache.redis = $redis

      Resque.redis = Redis.new(REDIS_CONNECTION_SETTINGS)
    end
  end
end
