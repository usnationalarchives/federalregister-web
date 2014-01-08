module Capybara::RSpecMatchers
  def click_nav_item(menu, link_text)
    within('#navigation') do
      page.find('a', :text => menu).trigger(:mouseover)
      click_link(link_text)
    end
  end

  def have_flash_notice(text)
    have_selector('.flash.notice', text: text)
  end
end
