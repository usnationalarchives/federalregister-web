module ContentNavHelper
  def content_nav_item(type:, icon:, label:, options: {}, wrapper_options: {}, &block)
    tooltip = if options[:tooltip]
      {
        delay: {show: 300, hide: 0},
        placement: "top",
        title: label
      }
    end

    content = tooltip_icon(
      icon,
      role: "button",
      "aria-label": label,
      data: tooltip,
      icon_badge: options.delete(:icon_badge)
    ) +
      content_tag(:span, label,
        class: "content-nav-label #{options.delete(:class)}",
        id: options.delete(:id),
        role: "button")

    content = block ? content + block.yield : content

    content_tag(:li, content,
      class: "#{type.to_s.gsub('_','-')} #{wrapper_options.delete(:class)}",
      title: wrapper_options.delete(:title),
      id: wrapper_options.delete(:id).to_s,
      tabindex: 0)
  end
end
