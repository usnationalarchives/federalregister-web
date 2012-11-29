module ApplicationHelper
  def page_title(text, options = {})
    options.symbolize_keys!
    
    content_for :page_title, strip_tags(text)
  end
end
