class SubscriptionDecorator < ApplicationDecorator
  decorates :subscription

  def type
    mailing_list.type.split('::').last
  end

  def search_url
    url = case type
          when "Article"
            "/articles/search"
          when "PublicInspectionDocument"
            "/public-inspection/search"
          end
    "#{url}?#{mailing_list.parameters.to_query}"
  end

  def sparkline_url
    url = case type
          when "Article"
            "/articles/search/activity/sparkline/weekly"
          when "PublicInspectionDocument"
            "/public-inspection/search/activity/sparkline/weekly"
          end
    "#{url}?#{mailing_list.parameters.to_query}"
  end

  def delivery_count
    model.delivery_count || 0
  end

  def subscribed_on
    created_at.to_formatted_s(:date)
  end

  def last_delivered_on
    if last_delivered_at
      last_delivered_at.to_formatted_s(:date)
    else
      "No items have matched since subscription started"
    end
  end
end
