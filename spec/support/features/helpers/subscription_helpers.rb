module Features
  module SubscriptionHelpers
    include Capybara::DSL

    def open_subscription_modal_from_title_bar
      subscription_link = page.find('.title a.subscription')
      subscription_link.click
    end
  end
end
