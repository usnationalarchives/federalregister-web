class WpApi::PageCollection < WpApi::Collection
  alias :pages :content

  def model
    WpApi::Page
  end
end
