module Capybara::RSpecMatchers
  def have_inline_error(element, text)
    within(element) do
      have_selector('p.inline-errors', text: text)
    end
  end

  def have_disabled_button(element, text)
    within(element) do
      have_selector("input[value='#{text}']:disabled")
    end
  end

  def have_invalid_email_message(element, text)
    within(element) do
      have_selector('.email_invalid', text: text)
    end
  end
end
