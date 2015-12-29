module ApplicationHelper
  def set_content_for(name, content = nil, &block)
    # clears out the existing content_for so that its set rather than appended to
    ivar = "@content_for_#{name}"
    instance_variable_set(ivar, nil)
    content_for(name, content, &block)
  end

  def title(args = {}, &block)
    header_class = args.fetch(:header_class){ '' }
    text = args.fetch(:text){ '' }
    title_bar_class = args.fetch(:title_bar_class){ '' }

    if block_given?
      unless @content_for_page_title
        page_title(capture(&block))
      end

      header = content_tag(:h1, class: header_class, &block)
    else
      # set the html title if we haven't already
      unless @content_for_page_title
        page_title(text)
      end

      header = content_tag(:h1, text, class: header_class)
    end

    title_bar = content_tag(:div, class: "main-title-bar #{title_bar_class}") do
      content_tag(:div, '', class: 'bar left') +
        header +
        content_tag(:div, '', class: 'bar right')
    end

    set_content_for :title_bar, title_bar
  end

  def page_title(text, options = {})
    set_content_for :page_title, strip_tags(text)
  end

  def description(text)
    set_content_for :description, strip_tags(text)
  end

  def feed_autodiscovery(feed_url, public_inspection_available, title = 'RSS', options = {})
    link_html_options = {
      rel: 'alternate',
      type: 'application/rss+xml',
      title: title,
      href: feed_url,
      class: 'subscription_feed'
    }

    if options[:search_conditions]
      link_html_options[:'data-search-conditions'] = options.
        fetch(:search_conditions).
        to_json
      link_html_options[:'data-public-inspection-subscription-supported'] = public_inspection_available
    end

    if options[:subscription_default]
      link_html_options[:'data-default-search-type'] = options.fetch(:subscription_default)
    end

    content_for :feeds, tag(:link, link_html_options)
  end

  def header_type(type)
    content_for :header_type, type
  end

  def open_graph_metadata(options={})
    set_content_for :og_type, strip_tags(options[:type]) if options[:type]
    set_content_for :og_published_time, strip_tags(options[:published_time]) if options[:published_time]
    set_content_for :og_image, strip_tags(options[:image_url]) if options[:image_url]
  end

  def pluralize_without_count(count, noun, text = nil)
    count == 1 ? "#{noun}#{text}" : "#{noun.pluralize}#{text}"
  end

  def clippy(url)
    content_tag(:span, class: "clippy_wrapper") do
      content_tag(:span, url, class: "clippy")
    end
  end

  def css_class(str)
    str.downcase.strip.gsub(/_|\s/, '-')
  end
end
