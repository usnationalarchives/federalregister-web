module LinkHelper
  def link_to_twitter(status)
    href = "http://twitter.com/home?status=#{CGI.escape status}"
    link_to('Twitter', href, :target => :blank, :title => 'Share on Twitter', :class => 'button list social twitter tip_over')
  end

  def link_to_facebook(url, title)
    link_to "Facebook", "http://www.facebook.com/sharer.php?u=#{CGI.escape url}&t=#{CGI.escape title}", :target => :blank, :class => 'button list fb_link social facebook tip_over', :title => "Share on Facebook"
  end

end
