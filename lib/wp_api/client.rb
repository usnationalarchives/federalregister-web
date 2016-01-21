class WpApi::Client
  class PageNotFound < StandardError; end

  include HTTParty
  base_uri "#{Settings.federal_register.base_uri}/blog/wp-json"

  def self.pages_endpoint
    "#{base_uri}/pages"
  end

  def self.posts_endpoint
    "#{base_uri}/posts"
  end

  def self.get_pages(options={})
    filters = options.fetch(:filters) { "" }
    filters = build_filters(filters) if filters.present?

    WpApi::PageCollection.new(
      get("#{pages_endpoint}?#{filters}")
    )
  end

  def self.get_page_by_slug(slug)
    page = get("#{pages_endpoint}?filter[name]=#{slug}").first

    raise PageNotFound.new("can't find page with slug '#{slug}'") unless page

    WpApi::Page.new(page)
  end

  def self.get_posts(options={})
    filters = options.fetch(:filters) { "" }
    filters = build_filters(filters) if filters.present?

    WpApi::PostCollection.new(
      get("#{posts_endpoint}?#{filters}")
    )
  end

  def self.search(term)
    page_collection = get_pages(filters: {s: term})
    post_collection = get_posts(filters: {s: term, posts_per_page: 10})

    WpApi::SearchResult.new(term, page_collection, post_collection)
  end

  private

  def self.get(uri)
    super( URI.encode(uri) )
  end

  def self.build_filters(filters)
    if filters[:parent_slug]
      slug = filters.delete(:parent_slug)
      parent_page = get_page_by_slug(slug)
      filters[:post_parent] = parent_page.id
    end

    filters.map do |key, value|
      "filter[#{key}]=#{value}"
    end.join('&')
  end
end
