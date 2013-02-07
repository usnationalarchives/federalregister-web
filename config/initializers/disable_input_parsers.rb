# Disable XML and JSON input parsing
#   to prevent typecasting security vulnerability
#   https://groups.google.com/forum/#!topic/rubyonrails-security/ZOdH5GH5jCU/discussion
ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML) 
ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::JSON)