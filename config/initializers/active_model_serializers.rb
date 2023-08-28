# turn off logging of serializer timing (similar to rail template render timings)
if Settings.active_model_serializers.disable_logging
  ActiveModelSerializers.logger = Logger.new(IO::NULL)
end
