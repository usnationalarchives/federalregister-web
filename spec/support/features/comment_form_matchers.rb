module Capybara::RSpecMatchers
  def have_comment_bar(element, text=nil)
    within('#comment-bar.comment') do
      HaveSelector.new(element, :text => text)
    end
  end
end
