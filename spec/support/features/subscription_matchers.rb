module Capybara::RSpecMatchers
  def have_subscriptions_metadata_item(element, text)
    within('#subscription_metadata_bar') do
      have_selector(element, text: text)
    end
  end

  def have_subscription_filter_enabled(type)
    within('#subscription-type-filter') do
      case type
      when 'Document'
        have_selector('.sub_article.on')
      when 'Public Inspection'
        have_selector('.sub_pi.on')
      end
    end
  end

  def toggle_subscription_filter(type)
    within('#subscription-type-filter') do
      case type
      when 'Document'
        find('.sub_article').click
      when 'Public Inspection'
        find('.sub_pi').click
      end
    end
  end

  def have_subscriptions_item(element, text=nil)
    within('#subscriptions') do
      if text
        have_selector(element, text: text)
      else
        have_selector(element)
      end
    end
  end
end
