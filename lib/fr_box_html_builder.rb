class FrBoxHtmlBuilder
  attr_reader :block, :box_obj, :view_context

  attr_accessor :box_html_options,
    :box_type,
    :content_block_options,
    :default_header_options,
    :header_options

  def initialize(box_obj, view_context, &block)
    @view_context = view_context
    @box_obj = box_obj
    @block = @view_context.capture(&block)

    options = box_obj.options
    @box_type = options.fetch(:box_type, :large)
    @box_html_options = options.fetch(:box_html, {})

    @content_block_options = options.fetch(:content_block_html, {})

    header_options = options.fetch(:header, {})
    default_header_options = {
      hover: true,
      seal: false
    }
    @header_options = default_header_options.merge!(header_options)
  end

  def fr_box
    view_context.content_tag(:div, class: "fr-box #{@box_obj.css_selector} #{@box_html_options[:class]}", role: @box_html_options[:role]) do
      fr_box_header +
      view_context.content_tag(:div, @block, class: "content-block #{@content_block_options[:class]}") +
      fr_box_footer
    end
  end

  def fr_box_small
    selector = combine_selectors("fr-box-small")

    @box_html_options.deep_merge!({class: selector})
    @box_type = :small

    fr_box
  end

  def fr_box_utility
    selector = combine_selectors("fr-box-full dropdown-menu dropdown-menu-right")
    update_to_menu_no_hover_config(selector)

    fr_box
  end

  def fr_box_tooltip
    selector = combine_selectors("fr-box-full")
    update_to_menu_no_hover_config(selector)

    fr_box
  end

  def fr_box_header
    view_context.content_tag(:div, class: "fr-seal-block fr-seal-block-header #{'with-hover' if @header_options[:hover]}") do
      view_context.content_tag(:div, class: "fr-seal-content") do
        description = @header_options[:hover] ? fr_box_header_description : "".html_safe

        view_context.content_tag(:h6, @box_obj.title) +
          description
      end
    end
  end

  def fr_box_header_description
    view_context.content_tag(:div, class: "fr-seal-meta") do
      html = @header_options[:seal] ? fr_box_seal : "".html_safe

      html +
      view_context.content_tag(:div, class: "fr-seal-desc") do
        if @header_options[:description]
          @header_options[:description].html_safe
        else
          view_context.content_tag(:p, @box_obj.description.html_safe)
        end
      end
    end
  end

  def fr_box_seal
    view_context.content_tag(:div, class: "fr-seal-stamp col-md-3 col-xs-3") do
      view_context.content_tag(:span, "", class: "fr-stamp icon-fr2 #{@box_obj.stamp_icon}")
    end
  end

  def fr_box_footer
    view_context.content_tag(:div, class: "fr-seal-block fr-seal-block-footer") do
      view_context.content_tag(:h6, @box_obj.title) unless @box_html_options[:suppress_footer_title]
    end
  end

  private

  def combine_selectors(selector)
    if @box_html_options[:class]
      @box_html_options[:class] + " " + selector
    else
      selector
    end
  end

  def update_to_menu_no_hover_config(selector)
    @box_html_options.deep_merge!({
      class: selector,
      role: "menu"
    })

    @header_options.deep_merge!({
      hover: false
    })
  end
end
