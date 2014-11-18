module Models
  module ApiHelpers
    def track_response_keys(hsh)
      $response_keys << hsh_keys(hsh)
      $response_keys.reject!(&:blank?)
      $response_keys.uniq!
      hsh
    end

    def hsh_keys(hsh, prefix=[])
      list = []
      hsh.each do |key, val|
        if val.is_a?(Hash)
          list += hsh_keys(val,prefix + [key])
        #elsif val.is_a?(Array)
        #  val.each do |v|
        #    list += hsh_keys(v,prefix + [key])
        #  end
        else
          list << prefix + [key]
        end
      end

      list
    end
  end
end
