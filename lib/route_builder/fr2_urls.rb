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

  def layout_head_content_path(page_to_track=nil)
    path = "/layout/head_content"

    if page_to_track
      path = "#{path}?page_to_track=#{page_to_track}"
    end

    path
  end

  def layout_header_path(header_type)
    "/layout/header?header_type=#{header_type}"
  end
end
