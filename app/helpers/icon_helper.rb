module IconHelper
  def fr_icon(name, options={})
    content_tag :span, '', class: "icon-fr2 icon-fr2-#{name} #{options[:class]}"
  end
end
