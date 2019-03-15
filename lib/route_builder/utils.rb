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

        Rails.application.routes.url_helpers.public_send(new_method_name, options)
      end
    end
  end

  # def self.define_route(route_name, &proc)
  #   define_method route_name do |*args|
  #     options = args.extract_options! || {}
  #
  #     if args.size > 0
  #       route_params = proc.call(*args)
  #       options.reverse_merge!(route_params)
  #     end
  #
  #     super(options)
  #   end
  # end
  #
  # def add_route(route_name, &proc)
  #   Rails.application.routes.named_routes.path_helpers_module.module_eval do
  #     RouteBuilder::Utils.define_route("#{route_name}_path", &proc)
  #   end
  #   Rails.application.routes.named_routes.url_helpers_module.module_eval do
  #     RouteBuilder::Utils.define_route("#{route_name}_url", &proc)
  #   end
  # end

  def add_static_route(route_name, &proc)
    define_method "#{route_name}_path" do |*args|
      proc.call(*args)
    end

    define_method "#{route_name}_url" do |*args|
      root_url.sub(/\/$/,'') + proc.call(*args)
    end
  end
end
