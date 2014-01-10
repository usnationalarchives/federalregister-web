class SubscriptionOnPage < Struct.new(:subscription_title)
  include Capybara::DSL

  def active?
    subscription_element.has_selector? '.subscription_data .active'
  end

  def visible?
    subscription_list.has_selector? 'li', text: subscription_title
  end

  private

  def subscription_element
    subscription_list.find 'li', text: subscription_title
  end

  def subscription_list
    find '#subscriptions'
  end
end
