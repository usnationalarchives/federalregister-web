module RouteBuilder::Fr2Urls
  extend RouteBuilder::Utils

  add_static_route :select_cfr_citation do |date, title, part, section|
    year     =  date.strftime('%Y')
    month    =  date.strftime('%m')
    day      =  date.strftime('%d')
    citation =  "#{title}-CFR-#{part}#{'.' + section.to_s if section.present?}"

    "/select-citation/#{year}/#{month}/#{day}/#{citation}"
  end

  add_static_route :executive_order do |executive_order_number|
    "/executive-order/#{executive_order_number}"
  end

  def citation_path(vol, page)
    "/citation/#{vol}/#{page}"
  end
end
