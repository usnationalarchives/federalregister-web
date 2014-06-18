module LinkHelper
  def link_to_twitter(status, link_text = "Twitter", icons=true)
    href = "http://twitter.com/home?status=#{CGI.escape status}"
    link_class = icons ? 'button list social twitter tip_over' : 'twitter'
    link_to(link_text, href, :target => :blank, :title => 'Share on Twitter', :class => link_class)
  end

  def link_to_facebook(url, title, link_text="Facebook", icons=true)
    href = "http://www.facebook.com/sharer.php?u=#{CGI.escape url}&t=#{CGI.escape title}"
    link_class = icons ? 'button list fb_link social facebook tip_over' : 'facebook'
    link_to(link_text, href, :target => :blank, :class => link_class, :title => "Share on Facebook")
  end
end
