class WpApi::PageCollection < WpApi::Collection
  alias :pages :content

  def model
    WpApi::Page
  end

  def pages_grouped_by_parent
    results = {}
    parents = content.
      map(&:parent)
    parents.each do |parent|
      results[parent] = content.select{|x| x.parent == parent}
    end
    results
  end
end
