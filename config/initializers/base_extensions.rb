class Object
  def try_if_exists(*args, &blk)
    if respond_to?(args.first)
      try(*args, &blk)
    end
  end
end

class Hash
  def seek(*_keys_)
    last_level    = self
    sought_value  = nil

    _keys_.each_with_index do |_key_, _idx_|
      if last_level.is_a?(Hash) && last_level.has_key?(_key_)
        if _idx_ + 1 == _keys_.length
          sought_value = last_level[_key_]
        else
          last_level = last_level[_key_]
        end
      else
        break
      end
    end

    sought_value
  end
end
