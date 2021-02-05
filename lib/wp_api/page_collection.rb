class WpApi::PageCollection < WpApi::Collection
  alias :pages :content

  def initialize(attributes)
    return [] if attributes == ["code", "rest_invalid_param"]
    super attributes
  end

  def model
    WpApi::Page
  end

  def pages_grouped_by_parent
    results = {}
    parents = content.
      select{|x| x.parent.present?}.
      map(&:parent).
      group_by(&:slug)

    parents.each do |slug, parents|
      results[parents.first] = content.select{|x| x.parent.present? && x.parent.slug == parents.first.slug}
    end

    results
  end
end
