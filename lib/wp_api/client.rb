class WpApi::Client
  class PageNotFound < StandardError; end

  include HTTParty
  base_uri "#{Settings.services.ofr.wordpress.internal_base_url}/blog/wp-json/wp/v2"

  ##############################
  # ENDPOINTS
  ##############################
  def self.categories_endpoint
    "#{base_uri}/categories"
  end

  def self.pages_endpoint
    "#{base_uri}/pages"
  end

  def self.posts_endpoint
    "#{base_uri}/posts"
  end

  def self.users_endpoint
    "#{base_uri}/users"
  end


  ##############################
  # CONTENT RETRIEVAL
  ##############################
  def self.get_categories
    get("#{categories_endpoint}").map do |attributes|
      WpApi::Category.new(attributes)
    end
  end

  def self.get_pages(params={})
    params = build_params(params)

    WpApi::PageCollection.new(
      get( build_url(pages_endpoint, params) )
    )
  end

  def self.get_page(params={})
    if params[:id]
      page = get("#{pages_endpoint}/#{params[:id]}")
    else
      params = build_params(params)
      page = get( build_url(pages_endpoint, params) ).first
    end

    raise PageNotFound.new("can't find page with params '#{params}'") unless page

    WpApi::Page.new(page)
  end

  def self.get_posts(params={})
    params = build_params(params)

    WpApi::PostCollection.new(
      get( build_url(posts_endpoint, params) )
    )
  end

  def self.search(term)
    page_collection = get_pages(search: term)
    post_collection = get_posts(search: term, per_page: 10)

    WpApi::SearchResult.new(term, page_collection, post_collection)
  end

  def self.get_users
    get("#{users_endpoint}").map do |attributes|
      WpApi::Author.new(attributes)
    end
  end

  private

  def self.get(uri)
    super( Addressable::URI.escape(uri) )
  end

  def self.build_url(endpoint, params)
    Rails.logger.info("WpApi url: [#{endpoint}, #{params}]")
    [endpoint, params].compact.join('?')
  end

  def self.build_params(params)
    if params[:parent_slug]
      slug = params.delete(:parent_slug)
      parent_page = get_page(slug: slug)
      params[:parent] = parent_page.id
    end

    params.present? ? params.to_query : nil
  end
end
