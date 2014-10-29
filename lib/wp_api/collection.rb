class WpApi::Collection
  attr_accessor :content

  def initialize(raw_content)
    @content = []
    parse_content(raw_content)
  end

  def parse_content(raw_content)
    raw_content.each{|item| content << model.new(item)}
    content.
      sort!{|a,b| b.modified <=> a.modified}
  end

  def find_by_parent(title)
    content.
      select{|item| item.parent_title == title}
  end
end
