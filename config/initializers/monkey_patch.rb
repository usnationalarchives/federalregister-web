# This seems to be a rails issue with sub-url's and sprockets asset compilation.
# It's supposed to be fixed in Rails 3.1 but that method doesn't seem to be working
# when compass is compiling sprite URLs. This patch makes it all work...
# Requires that we set ENV['RAILS_RELATIVE_URL_ROOT'] at the top of environment.rb
# See https://github.com/rails/sass-rails/issues/17 and follow the rabbit hole...
module Sass
  module Rails
    module Helpers
      protected
      def public_path(asset, kind)
        resolver = options[:custom][:resolver]
        asset_paths = resolver.context.asset_paths
        path = resolver.public_path(asset, kind.pluralize)
        if !asset_paths.send(:has_request?) && ENV['RAILS_RELATIVE_URL_ROOT']
          path = ENV['RAILS_RELATIVE_URL_ROOT'] + path
        end
        path
      end
    end
  end
end
