REDIS_CONNECTION_SETTINGS = {
  :db   => SECRETS['redis']['db'],
  :host => SECRETS['redis']['host'],
  :port => SECRETS['redis']['port']
}

redis = Redis.new(REDIS_CONNECTION_SETTINGS)

$redis = Redis::Namespace.new(
  SECRETS['redis']['namespace'],
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
        SECRETS['redis']['namespace'],
        :redis => Redis.new(REDIS_CONNECTION_SETTINGS)
      )

      HTTParty::HTTPCache.redis = $redis

      Resque.redis = $redis
    end
  end
end
