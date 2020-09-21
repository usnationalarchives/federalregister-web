module ModalHelper
  def modal(type, options={}, &block)
    case type
    when :basic
      basic_modal(options, &block)
    when :with_button
      modal_with_button(options, &block)
    end
  end

  def basic_modal(options, &block)
    header = modal_header(options)

    render partial: 'modals/basic_modal',
      locals: {
        header: options.fetch(:header) { true },
        header_close_button: options.fetch(:header_close_button) { true },
        modal_id: options.fetch(:modal_id) { "generic-modal" },
        modal_class: options.fetch(:modal_class) { "" },
        modal_header: header,
        modal_body: capture(&block),
        footer: options.fetch(:footer) { true },
        open_on_page_load: options.fetch(:open_on_page_load) { false },
        set_cookie: options.fetch(:set_cookie) { false },
      }
  end

  def modal_header(options)
    header = []
    if options[:header_icon]
      header << "<span class='icon-cpp #{options[:header_icon]}'></span>"
    end
    header << options.fetch(:header_text) { "Generic Modal" }

    header.join("\n").html_safe
  end

  def link_to_modal(text, modal_id, options={})
    link_to text, modal_id, class: "modal-link #{options.delete(:class)}"
  end

  def link_to_modal_with_icon(text, modal_id, options = {})
    icon_class = options.delete(:icon)

    raise ":icon required for link_to_modal_with_icon" unless icon_class

    icons = icon_class.split(' ').map{|icon| ecfr_icon(icon)}
    link_to_modal("#{icons.join(' ')} #{text}".html_safe, modal_id, options)
  end

  def modal_javascript(modal_id, options={})
    content_for :modal_javascript do
      html = <<-HTML
        <script type='text/javascript'>
          var MODAL = {
            modalTarget: '##{modal_id}',
            setCookie: #{options.fetch(:set_cookie){false}}
          };
        </script>
      HTML

      html.html_safe
    end
  end
end
