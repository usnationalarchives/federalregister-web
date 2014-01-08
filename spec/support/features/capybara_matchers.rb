module Capybara::RSpecMatchers
  def have_user_util(element, text)
    within('#user_utils') do
      HaveSelector.new(element, :text => text)
    end
  end

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

  def click_nav_item(menu, link_text)
    within('#navigation') do
      page.find('a', :text => menu).trigger(:mouseover)
      click_link(link_text)
    end
  end

  def click_user_util_item(link_text)
    within('#user_utils') do
      click_link(link_text)
    end
  end

  def clip_current_document
    page.find("#add-to-folder").click
  end
end
