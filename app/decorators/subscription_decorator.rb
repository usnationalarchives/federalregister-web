class SubscriptionDecorator < ApplicationDecorator
  decorates :subscription

  def type
    mailing_list.type.split('::').last
  end

  def icon_class
    type == "Article" ? "icon-fr2-document_subscription" : "icon-fr2-pi_subscription"
  end

  def search_path(options={})
    format = options.delete(:format)

    url = case type
          when "Article"
            "/articles/search#{format if format}"
          when "PublicInspectionDocument"
            "/public-inspection/search#{format if format}"
          end
    
    "#{url}?#{mailing_list.parameters.merge(options).to_query}"
  end

  def sparkline_url
    url = case type
          when "Article"
            "/articles/search/activity/sparkline/weekly"
          when "PublicInspectionDocument"
            "/public-inspection/search/activity/sparkline/weekly"
          end
    
    chart_params = {:chart_options => {:chart_bg_color => 'F5F8F9'}}

    "#{url}?#{chart_params.to_query}&#{mailing_list.parameters.to_query}"
  end


  def delivery_count
    model.delivery_count || 0
  end

  def subscribed_on
    created_at
  end

  def last_delivered_on
    if last_delivered_at
      last_delivered_at
    else
      "No items have matched since subscription started"
    end
  end
end
