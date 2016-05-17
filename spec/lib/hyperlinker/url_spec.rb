# encoding: UTF-8
require File.dirname(__FILE__) + '/../../spec_helper'

# cribbed from https://github.com/tenderlove/rails_autolink/blob/master/test/test_rails_autolink.rb

describe Hyperlinker::Url do
  def hyperlink(text, options={})
    Hyperlinker::Url.perform(text, options)
  end

  def h(str)
    ERB::Util.html_escape(str)
  end

  def generate_result(link_text, href = nil)
    href ||= link_text
    %{<a href="#{CGI::escapeHTML(href)}">#{Hyperlinker::Url.add_line_break_indicators(link_text)}</a>}.gsub(/'/,'&#x27;')
  end

  it "handles brackets" do
    link1_raw = 'http://en.wikipedia.org/wiki/Sprite_(computer_graphics)'
    link1_result = generate_result(link1_raw)
    expect(hyperlink(link1_raw)).to eql( link1_result )
    expect(hyperlink("(link: #{link1_raw})")).to eql("(link: #{link1_result})")

    link2_raw = 'http://en.wikipedia.org/wiki/Sprite_[computer_graphics]'
    link2_result = generate_result(link2_raw)
    expect(hyperlink(link2_raw)).to eql( link2_result )
    expect(hyperlink("[link: #{link2_raw}]")).to eql("[link: #{link2_result}]")

    link3_raw = 'http://en.wikipedia.org/wiki/Sprite_{computer_graphics}'
    link3_result = generate_result(link3_raw)
    expect(hyperlink(link3_raw)).to eql( link3_result )
    expect(hyperlink("{link: #{link3_raw}}")).to eql("{link: #{link3_result}}")
  end

  it "handles multiple trailing punctuations" do
    url = "http://youtube.com"
    url_result = generate_result(url)
    expect(hyperlink(url)).to eql url_result
    expect(hyperlink("(link: #{url}).")).to eql "(link: #{url_result})."
  end

  it "handles EOL" do
    url1 = "http://api.rubyonrails.com/Foo.html"
    url2 = "http://www.ruby-doc.org/core/Bar.html"

    expect(hyperlink("<p>#{url1}<br />#{url2}<br /></p>")).to eql %(<p><a href="#{url1}">http://api.rubyonrails.com/&#8203;Foo.html</a><br /><a href="#{url2}">http://www.ruby-doc.org/&#8203;core/&#8203;Bar.html</a><br /></p>)
  end

  it "handle misc formatting" do
    link_raw     = 'http://www.rubyonrails.com'
    link_result  = generate_result(link_raw)
    link_result_with_options = %{<a href="#{link_raw}" target="_blank">#{link_raw}</a>}

    expect(hyperlink(nil)).to eql('')
    expect(hyperlink('')).to eql('')
    expect(hyperlink("#{link_raw} #{link_raw} #{link_raw}")).to eql("#{link_result} #{link_result} #{link_result}")

    expect(hyperlink("Go to #{link_raw}")).to eql(%(Go to #{link_result}))
    expect(hyperlink("<p>Link #{link_raw}</p>")).to eql(%(<p>Link #{link_result}</p>))
    expect(hyperlink("<p>#{link_raw} Link</p>")).to eql(%(<p>#{link_result} Link</p>))
    expect(hyperlink("<p>Link #{link_raw}</p>", {:target => "_blank"})).to eql(%(<p>Link #{link_result_with_options}</p>))
    expect(hyperlink(%(Go to #{link_raw}.))).to eql(%(Go to #{link_result}.))

    link2_raw    = 'www.rubyonrails.com'
    link2_result = generate_result(link2_raw, "http://#{link2_raw}")
    expect(hyperlink("Go to #{link2_raw}")).to eql(%(Go to #{link2_result}))
    expect(hyperlink("<p>Link #{link2_raw}</p>")).to eql(%(<p>Link #{link2_result}</p>))
    expect(hyperlink("<p>#{link2_raw} Link</p>")).to eql(%(<p>#{link2_result} Link</p>))
    expect(hyperlink(%(Go to #{link2_raw}.))).to eql(%(Go to #{link2_result}.))

    link3_raw    = 'http://manuals.ruby-on-rails.com/read/chapter.need_a-period/103#page281'
    link3_result = generate_result(link3_raw)
    expect(hyperlink("Go to #{link3_raw}")).to eql(%(Go to #{link3_result}))
    expect(hyperlink("<p>Link #{link3_raw}</p>")).to eql(%(<p>Link #{link3_result}</p>))
    expect(hyperlink("<p>#{link3_raw} Link</p>")).to eql(%(<p>#{link3_result} Link</p>))
    expect(hyperlink(%(Go to #{link3_raw}.))).to eql(%(Go to #{link3_result}.))

    link4_raw    = 'http://foo.example.com/controller/action?parm=value&p2=v2#anchor123'
    link4_result = generate_result(link4_raw)
    expect(hyperlink("<p>Link #{link4_raw}</p>")).to eql(%(<p>Link #{link4_result}</p>))
    expect(hyperlink("<p>#{link4_raw} Link</p>")).to eql(%(<p>#{link4_result} Link</p>))

    link5_raw    = 'http://foo.example.com:3000/controller/action'
    link5_result = generate_result(link5_raw)
    expect(hyperlink("<p>#{link5_raw} Link</p>")).to eql(%(<p>#{link5_result} Link</p>))

    link6_raw    = 'http://foo.example.com:3000/controller/action+pack'
    link6_result = generate_result(link6_raw)
    expect(hyperlink("<p>#{link6_raw} Link</p>")).to eql(%(<p>#{link6_result} Link</p>))

    link7_raw    = 'http://foo.example.com/controller/action?parm=value&p2=v2#anchor-123'
    link7_result = generate_result(link7_raw)
    expect(hyperlink("<p>#{link7_raw} Link</p>")).to eql(%(<p>#{link7_result} Link</p>))

    link8_raw    = 'http://foo.example.com:3000/controller/action.html'
    link8_result = generate_result(link8_raw)
    expect(hyperlink("Go to #{link8_raw}")).to eql(%(Go to #{link8_result}))
    expect(hyperlink("<p>Link #{link8_raw}</p>")).to eql(%(<p>Link #{link8_result}</p>))
    expect(hyperlink("<p>#{link8_raw} Link</p>")).to eql(%(<p>#{link8_result} Link</p>))
    expect(hyperlink(%(Go to #{link8_raw}.))).to eql(%(Go to #{link8_result}.))

    link9_raw    = 'http://business.timesonline.co.uk/article/0,,9065-2473189,00.html'
    link9_result = generate_result(link9_raw)
    expect(hyperlink("Go to #{link9_raw}")).to eql(%(Go to #{link9_result}))
    expect(hyperlink("<p>Link #{link9_raw}</p>")).to eql(%(<p>Link #{link9_result}</p>))
    expect(hyperlink("<p>#{link9_raw} Link</p>")).to eql(%(<p>#{link9_result} Link</p>))
    expect(hyperlink(%(Go to #{link9_raw}.))).to eql(%(Go to #{link9_result}.))

    link10_raw    = 'http://www.mail-archive.com/ruby-talk@ruby-lang.org/'
    link10_result = generate_result(link10_raw)
    expect(hyperlink("<p>#{link10_raw} Link</p>")).to eql(%(<p>#{link10_result} Link</p>))

    link11_raw    = 'http://asakusa.rubyist.net/'
    link11_result = generate_result(link11_raw)
    expect(hyperlink("浅草.rbの公式サイトはこちら#{link11_raw}")).to eql(%(浅草.rbの公式サイトはこちら#{link11_result}))

    link12_raw    = 'http://tools.ietf.org/html/rfc3986'
    link12_result = generate_result(link12_raw)
    expect(hyperlink("<p>#{link12_raw} text-after-nonbreaking-space</p>")).to eql(%(<p>#{link12_result} text-after-nonbreaking-space</p>))

    link13_raw    = 'HTtP://www.rubyonrails.com'
    expect(hyperlink(link13_raw)).to eql(generate_result(link13_raw))
  end

  it "handles www2 URLs" do
    link_raw    = 'www2.ed.gov'
    link_result = generate_result(link_raw, "http://#{link_raw}")
    expect(hyperlink("Go to #{link_raw}")).to eql(%(Go to #{link_result}))
  end

  it "doesn't match non-URLs" do
    %w(foo http:// https://).each do |fragment|
      expect(hyperlink(fragment)).to eql fragment
    end
  end

  it "handles variety of URL formats" do
    urls = %w(
      http://www.rubyonrails.com
      http://www.rubyonrails.com:80
      http://www.rubyonrails.com/~minam
      https://www.rubyonrails.com/~minam
      http://www.rubyonrails.com/~minam/url%20with%20spaces
      http://www.rubyonrails.com/foo.cgi?something=here
      http://www.rubyonrails.com/foo.cgi?something=here&and=here
      http://www.rubyonrails.com/contact;new
      http://www.rubyonrails.com/contact;new%20with%20spaces
      http://www.rubyonrails.com/contact;new?with=query&string=params
      http://www.rubyonrails.com/~minam/contact;new?with=query&string=params
      http://en.wikipedia.org/wiki/Wikipedia:Today%27s_featured_picture_%28animation%29/January_20%2C_2007
      http://www.mail-archive.com/rails@lists.rubyonrails.org/
      http://www.amazon.com/Testing-Equal-Sign-In-Path/ref=pd_bbs_sr_1?ie=UTF8&s=books&qid=1198861734&sr=8-1
      http://en.wikipedia.org/wiki/Texas_hold'em
      https://www.google.com/doku.php?id=gps:resource:scs:start
      http://connect.oraclecorp.com/search?search[q]=green+france&search[type]=Group
      http://of.openfoundry.org/projects/492/download#4th.Release.3
      http://maps.google.co.uk/maps?f=q&q=the+london+eye&ie=UTF8&ll=51.503373,-0.11939&spn=0.007052,0.012767&z=16&iwloc=A
      http://около.кола/колокола
    )

    urls.each do |url|
      expect(hyperlink(url)).to eql generate_result(url)
    end
  end

  it "handles trailing equals on link" do
    url = "http://www.rubyonrails.com/foo.cgi?trailing_equals="
    expect(hyperlink(url)).to eql generate_result(url)
  end

  it "handles trailings amperand on link" do
    url = "http://www.rubyonrails.com/foo.cgi?trailing_ampersand=value&"
    expect(hyperlink(url)).to eql generate_result(url)
  end

  it "doesn't link previously linked" do
    linked_1 = generate_result('Ruby On Rails', 'http://www.rubyonrails.com')
    linked_2 = %('<a href="http://www.example.com">www.example.com</a>')
    linked_3 = %('<a href="http://www.example.com" rel="nofollow">www.example.com</a>')
    linked_4 = %('<a href="http://www.example.com"><b>www.example.com</b></a>')
    linked_5 = %('<a href="#close">close</a> <a href="http://www.example.com"><b>www.example.com</b></a>')

    expect(hyperlink(linked_1)).to eq(linked_1)
    expect(hyperlink(linked_2)).to eq(linked_2)
    expect(hyperlink(linked_3)).to eq(linked_3)
    expect(hyperlink(linked_4)).to eq(linked_4)
    expect(hyperlink(linked_5)).to eq(linked_5)
  end

  it "handles previously escaped input" do
    result = hyperlink(<<-XML)
      <E T="03">
        http://energy.gov/foo?a=1&amp;b=2
      </E>
    XML
    expect(result).to eql(<<-XML)
      <E T="03">
        <a href="http://energy.gov/foo?a=1&amp;b=2">http://energy.gov/&#8203;foo?&#8203;a=&#8203;1&amp;&#8203;b=&#8203;2</a>
      </E>
    XML
  end

  it "handles PRTPAGE" do
    result = hyperlink(<<-XML)
      <E T="03">
        http://
        <PRTPAGE P="81301"/>
        energy.gov/fe/2015-lng-study
      </E>
    XML

    expect(result).to eql(<<-XML)
      <E T="03">
        <a href="http://energy.gov/fe/2015-lng-study">http://</a>
        <PRTPAGE P="81301"/>
        <a href="http://energy.gov/fe/2015-lng-study">energy.gov/&#8203;fe/&#8203;2015-lng-study</a>
      </E>
    XML

    result = hyperlink(<<-XML)
      <E T="03">
        http://www.energy.gov/fe/2015-
        <PRTPAGE P="81301"/>
        lng-study
      </E>
    XML

    expect(result).to eql(<<-XML)
      <E T="03">
        <a href="http://www.energy.gov/fe/2015-lng-study">http://www.energy.gov/&#8203;fe/&#8203;2015-</a>
        <PRTPAGE P="81301"/>
        <a href="http://www.energy.gov/fe/2015-lng-study">lng-study</a>
      </E>
    XML

    result = hyperlink(<<-XML)
      <E T="03">
        http://www.energy.gov/fe/2015/
        <PRTPAGE P="81301"/>
        foo/bar/baz?a=1&b=2. a very interesting piece
      </E>
    XML

    expect(result).to eql(<<-XML)
      <E T="03">
        <a href="http://www.energy.gov/fe/2015/foo/bar/baz?a=1&amp;b=2">http://www.energy.gov/&#8203;fe/&#8203;2015/&#8203;</a>
        <PRTPAGE P="81301"/>
        <a href="http://www.energy.gov/fe/2015/foo/bar/baz?a=1&amp;b=2">foo/&#8203;bar/&#8203;baz?&#8203;a=&#8203;1&amp;&#8203;b=&#8203;2</a>. a very interesting piece
      </E>
    XML
  end
end
