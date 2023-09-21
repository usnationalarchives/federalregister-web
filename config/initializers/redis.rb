REDIS_CONNECTION_SETTINGS = {
  db: Settings.redis.db,
  host: Settings.redis.host || Rails.application.credentials.dig(:redis, :host),
  port: Settings.redis.port
}

$redis = Redis.new(REDIS_CONNECTION_SETTINGS)
