module Capybara::RSpecMatchers
  def have_subscriptions_metadata_item(element, text)
    within('#subscription_metadata_bar') do
      have_selector(element, text: text)
    end
  end
end
