module Ecfr
  class EcfrError < StandardError
    attr_reader :record

    def initialize(msg, record=nil)
      @record = record
      super(msg)
    end
  end

  class RecordNotFound < EcfrError; end
end
