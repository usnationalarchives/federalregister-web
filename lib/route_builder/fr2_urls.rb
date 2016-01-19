module RouteBuilder::Fr2Urls
  extend RouteBuilder::Utils

  add_static_route :executive_order do |executive_order_number|
    "/executive-order/#{executive_order_number}"
  end

  def citation_path(vol, page)
    "/citation/#{vol}-FR-#{page}"
  end
end
