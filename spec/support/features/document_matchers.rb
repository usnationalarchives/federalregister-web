module Capybara::RSpecMatchers
  def have_metadata_content(selector, text=nil, options={})
    within('#metadata_content_area') do
      if text.present?
        options.merge!(text: text)
        have_selector(selector, options)
      else
        have_selector(selector, options)
      end
    end
  end

  def have_metadata_link_with_content(selector, url, text)
    within('#metadata_content_area') do
      have_selector(selector + " a[href='#{url}']", text: text)
    end
  end

  def have_metadata_share_bar(selector, text=nil)
    within('#metadata_content_area .metadata_share_bar') do
      if text.present?
        have_selector(selector, text: text)
      else
        have_selector(selector)
      end
    end
  end
end
