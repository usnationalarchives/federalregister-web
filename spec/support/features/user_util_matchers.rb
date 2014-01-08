module Capybara::RSpecMatchers
  def have_user_util(element, text)
    within('#user_utils') do
      HaveSelector.new(element, :text => text)
    end
  end

  def click_user_util_item(link_text)
    within('#user_utils') do
      click_link(link_text)
    end
  end
end
