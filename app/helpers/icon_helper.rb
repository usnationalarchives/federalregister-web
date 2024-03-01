module IconHelper
  def fr_icon(name, options={})
    css_class = options.delete(:class) if options[:class]
    options.merge!(
      class: "icon-fr2 icon-fr2-#{name} #{css_class}"
    )

    icon_content = if options[:icon_badge]
      content_tag(:span, class: "comment_count") do
        options[:icon_badge]
      end
    else
      ''
    end

    content_tag(:span, icon_content, options)
  end

  def svg_icon(name, options = {})
    css_class = options.delete(:class) if options[:class]
    options[:class] = "svg-icon svg-icon-#{name} #{css_class}"

    content_tag(:svg, "", options) do
      content_tag(:use, "",
        "xlink:href" => "#{asset_path("fr-icons.svg")}##{name}")
    end
  end

  def tooltip_icon(icon, options = {})
    default_options = {
      :class => "svg-tooltip",
      "data-toggle" => "tooltip",
      "data-title" => options.dig(:data, :title) || "PLACEHOLDER"
    }

    options = default_options.merge(options)
    icon_options = options.delete(:icon_options) || {}

    unless options[:class].include?("svg-tooltip")
      options[:class].concat(" svg-tooltip")
    end

    content_tag(:span, "", options) do
      svg_icon(icon, icon_options)
    end
  end

  def copy_icon(text)
    tooltip_icon("content-copy", {
      :class => "copy-to-clipboard",
      "data-title" => t("clipboard.copy"),
      "data-title-copied" => t("clipboard.copied"),
      "data-copy-text" => text
    })
  end

  def clickable_icon(text, url, icon: "info-circle", options: {})
    tooltip_icon(icon,
      {
        :class => "clickable",
        "data-title" => text,
        "data-url" => url
      }.merge(options))
  end
end
