class WpApi::Collection
  attr_reader :content, :client
  def initialize(client, raw_content)
    @client = client
    @content = []
    parse_content(raw_content)
  end

  def parse_content(raw_content)
    raw_content.each{|item| content << model.new(item)}
    content.
      sort!{|a,b| b.get(:modified).to_date <=> a.get(:modified).to_date}
  end

  def find_by_parent(title)
    content.
      select{|item| item.parent_title == title}
  end
end
