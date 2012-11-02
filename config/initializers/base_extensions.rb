class Object
  def try_if_exists(*args, &blk)
    if respond_to?(args.first)
      try(*args, &blk)
    end
  end
end