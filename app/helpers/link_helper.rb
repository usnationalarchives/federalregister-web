module LinkHelper
  def link_to_twitter(link_text, status)
    href = "http://twitter.com/home?status=#{CGI.escape status}"
    link_to link_text, href,
      class: 'social twitter',
      target: :blank,
      title: 'Share on Twitter'
  end

  def link_to_facebook(link_text, url, title)
    href = "http://www.facebook.com/sharer.php?u=#{CGI.escape url}&t=#{CGI.escape title}"
    link_to link_text, href,
      class: 'social facebook',
      target: :blank,
      title: "Share on Facebook"
  end
end
