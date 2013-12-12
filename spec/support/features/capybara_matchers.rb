module Capybara::RSpecMatchers
  def have_user_util(element, text)
    within('#user_utils') do
      HaveSelector.new(element, :text => text)
    end
  end
end
