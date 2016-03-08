module DisqusHelper
  def disqus_comments_for(args={})
    raise "title and slug are required for disqus comment integration" unless args[:title] && args[:slug]

    url = "#{Settings.federal_register.base_uri}/#{args[:slug]}"
    identifier = Digest::MD5.new.update(url).hexdigest

    render partial: 'layouts/disqus_comments', locals: {
      identifier: identifier,
      title: args[:title],
      url: url
    }
  end
end
