module Models
  module ApiHelpers
    def track_response_keys(hsh)
      $response_keys << hsh.keys
      $response_keys.flatten!.uniq!
      hsh
    end
  end
end
