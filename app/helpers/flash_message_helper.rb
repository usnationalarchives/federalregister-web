module FlashMessageHelper
  def flash_message(type, options={}, &block)
    content_tag :p, class: "flash-message #{type}" do
      capture(&block)
    end
  end
end
