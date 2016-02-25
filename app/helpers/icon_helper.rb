module IconHelper
  def fr_icon(name, options={})
    css_class = options.delete(:class) if options[:class]
    options.merge!(
      class: "icon-fr2 icon-fr2-#{name} #{css_class}"
    )

    content_tag(:span, '', options)
  end
end
