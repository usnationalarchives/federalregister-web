module SubscriptionHelper

  def status_for_subscription(subscription)
    [ content_tag(:dt, 'Status:', :class => subscription.active? ? 'unsubscribe_link' : 'resubscribe_link'),
      content_tag(:dd) do
        content_tag(:span, subscription.active? ? 'active' : 'inactive', :class =>  subscription.active? ? 'active' : 'inactive')
      end
    ].join("\n").html_safe
  end

  def subscribe_box(search_conditions={}, options={})
    render partial: 'components/subscribe_box', locals: {
      options: options,
      search_conditions: search_conditions
    }
  end

  def subscribe_link(search_conditions={}, options={})
    if options[:custom_path]
      path = options[:custom_path]
    else
      path = ''
    end

    link_text = []
    link_text << fr_icon('message') unless options[:rss_only]
    link_text << fr_icon('rss')
    link_text << (options[:rss_only] ? "Subscribe via RSS" : "Subscribe")

    link_to(path, class: "subscription subscription_action #{options[:class]} #{'rss-only' if options[:rss_only]}") do
      link_text.join(" ").html_safe
    end
  end
end
