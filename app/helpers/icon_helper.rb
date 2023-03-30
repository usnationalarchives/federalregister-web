module IconHelper
  def fr_icon(name, options={})
    css_class = options.delete(:class) if options[:class]
    options.merge!(
      class: "icon-fr2 icon-fr2-#{name} #{css_class}"
    )

    content_tag(:span, '', options)
  end

  def sprite_icon(name, options={}, width: "32", height: "32", fill: "currentColor")
    tag.svg(class: "bi", width: width, height: height, fill: fill) do
      tag.use("xlink:href" => "#{asset_path('fr-icons.svg')}##{name}")
    end
  end

end
