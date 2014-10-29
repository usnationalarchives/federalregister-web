require 'will_paginate/array'

module WillPaginate
  module CollectionMethods
    attr_accessor :custom_page_count
    def total_pages
      @custom_page_count || (options.delete(:page_count) || (total_entries.zero? ? 1 : (total_entries / per_page.to_f).ceil))
    end
  end
end
