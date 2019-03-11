# Configure HTTParty API caching
HTTParty::HTTPCache.logger = Rails.logger
HTTParty::HTTPCache.timeout_length = 30 # seconds
HTTParty::HTTPCache.cache_stale_backup_time = 120 # seconds
