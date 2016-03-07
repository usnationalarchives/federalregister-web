module DisqusHelper
  def disqus_comments_for(options={})
    raise "title and url are required for disqus comment integration" unless options[:title] && options[:url]

    url = "#{Settings.federal_register.base_uri}/#{slug}"
    identifier = Digest::MD5.new.update(url).hexdigest

    render partial: 'layouts/disqus_comments', locals: {
      identifier: identifier,
      title: title,
      url: url
    }
  end
end
