module RouteBuilder::Utils
  def add_route(route_name, &proc)
    %w(path url).each do |type|
      new_method_name = "#{route_name}_#{type}"      # eg document_path

      define_method new_method_name do |*args|
        options = args.extract_options! || {}

        if args.size > 0
          route_params = proc.call(*args)
          options.reverse_merge!(route_params)
        end

        super(options)
      end
    end
  end

  def add_static_route(route_name, &proc)
    define_method "#{route_name}_path" do |*args|
      proc.call(*args)
    end

    define_method "#{route_name}_url" do |*args|
      root_url.sub(/\/$/,'') + proc.call(*args)
    end
  end
end
