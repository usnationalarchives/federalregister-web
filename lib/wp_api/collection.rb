class WpApi::Collection
  attr_accessor :content

  def initialize(raw_content)
    @content = []
    parse_content(raw_content)
  end

  def parse_content(raw_content)
    raw_content.each{|item| content << model.new(item)}
  end

  def find_by_parent(slug)
    content.
      select{|item| item.parent.slug == slug}
  end
end
