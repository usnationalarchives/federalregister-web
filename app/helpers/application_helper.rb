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

  def header_type(type)
    content_for :header_type, type
  end

  def meta_description(text)
    set_content_for :description, strip_tags(text)
  end

  def pluralize_without_count(count, noun, text = nil)
    count == 1 ? "#{noun}#{text}" : "#{noun.pluralize}#{text}"
  end

  def clippy(url)
    content_tag(:span, class: "clippy_wrapper") do
      content_tag(:span, url, class: "clippy")
    end
  end

  def bootstrap_context_wrapper(&block)
    render partial: 'special/helpers/bootstrap_context_wrapper', locals: {content: capture(&block)}
  end

  def add_nara_background_seal?(header_type)
    header_type == 'official'
  end
end
