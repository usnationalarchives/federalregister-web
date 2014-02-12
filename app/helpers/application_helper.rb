module ApplicationHelper
  def set_content_for(name, content = nil, &block)
    # clears out the existing content_for so that its set rather than appended to
    ivar = "@content_for_#{name}"
    instance_variable_set(ivar, nil)
    content_for(name, content, &block)
  end

  def page_title(text, options = {})
    options.symbolize_keys!

    content_for :page_title, strip_tags(text)

    unless options[:body] == false
      set_content_for :precolumn, content_tag(:h1, text)
    end
  end

  def meta_description(text)
    set_content_for :description, strip_tags(text)
  end
end
