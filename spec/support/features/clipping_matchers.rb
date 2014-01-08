module Capybara::RSpecMatchers
  def have_clipping_action(element, text)
    within('#clipping-actions') do
      HaveSelector.new(element, :text => text)
    end
  end

  def have_clipping_with_title(text)
    within('#clippings') do
      have_selector('.title a', text: text)
    end
  end

  def clip_current_document
    page.find("#add-to-folder").click
  end
end
