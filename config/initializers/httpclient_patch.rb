require 'httpclient'
class HTTPClient
  alias original_initialize initialize

  def initialize(*args, &block)
    original_initialize(*args, &block)

    # Force use of the default system CA certs
    @session_manager&.ssl_config&.set_default_paths
  end
end
