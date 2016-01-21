class WpApi::PageCollection < WpApi::Collection
  alias :pages :content

  def model
    WpApi::Page
  end

  def pages_grouped_by_parent
    results = {}
    parents = content.map(&:parent).group_by(&:slug)

    parents.each do |slug, parents|
      results[parents.first] = content.select{|x| x.parent.slug == parents.first.slug}
    end

    results
  end
end
