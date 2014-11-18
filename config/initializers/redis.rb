REDIS_CONFIG = YAML.load_file(Rails.root+'config/redis.yml')[Rails.env].freeze

redis = Redis.new(
  :host => REDIS_CONFIG['host'],
  :port => REDIS_CONFIG['port']
)

$redis = Redis::Namespace.new(
  REDIS_CONFIG['namespace'],
  :redis => redis
)

HTTParty::HTTPCache.redis = $redis
