class WpApi::PostCollection < WpApi::Collection
  alias :posts :content

  def model
    WpApi::Post
  end
end
