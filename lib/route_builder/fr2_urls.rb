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
    "/citation/#{vol}-FR-#{page}"
  end

  def layout_head_content_path
    "/layout/head_content"
  end

  def layout_header_path(header_type)
    "/layout/header?header_type=#{header_type}"
  end
end
