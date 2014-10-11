class WpApi::Client
  include HTTParty
  base_uri "https://www.fr2.criticaljuncture.org/blog/wp-json"

  default_options.update(verify: false)

  def self.get_pages
    params = "/pages?filter[posts_per_page]=1000"
    WpApi::PageCollection.new(
      self,
      self.get(base_uri + params)
    )
  end

  def self.get_posts
    params = "/posts"
    WpApi::PostCollection.new(
      self,
      self.get(base_uri + params)
    )
  end
end
