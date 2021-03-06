module Capybara::RSpecMatchers
  def click_nav_item(menu, link_text)
    within('#navigation') do
      page.find('a', :text => menu).trigger(:mouseover)
      click_link(link_text)
    end
  end

  def have_page_title(text)
    have_selector('h2.title', text: text)
  end

  def have_flash_notice(text)
    have_selector('.flash.notice', text: text)
  end

  def have_flash_error(text)
    have_selector('.flash.error', text: text)
  end

  def have_flash_warning(text)
    have_selector('.flash.warning', text: text)
  end

  def have_fr_warning_message(text='')
    have_selector('.warning.message', text: text)
  end

  def have_fr_notice_message(text='')
    have_selector('.notice.message', text: text)
  end

  def have_modal(id='#modal')
    have_selector(id)
  end

  def have_modal_element(element)
    within('#modal') do
      have_selector(element)
    end
  end
end
