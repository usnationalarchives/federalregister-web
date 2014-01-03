module Capybara::RSpecMatchers
  def have_comment_bar(element, text=nil)
    within('#flash_message.comment') do
      HaveSelector.new(element, :text => text)
    end
  end
end
